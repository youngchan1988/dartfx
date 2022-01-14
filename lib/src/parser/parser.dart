// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/error_token.dart';
import 'package:dartfx/src/lexer/tokens/keyword_token.dart';
import 'package:dartfx/src/lexer/tokens/string_token.dart';

import '../messages/codes.dart' as codes;

import '../lexer/tokens/token.dart';

import '../lexer/tokens/token_constants.dart'
    show
        BANG_EQ_EQ_TOKEN,
        COMMA_TOKEN,
        DOUBLE_TOKEN,
        EOF_TOKEN,
        EQ_EQ_EQ_TOKEN,
        EQ_TOKEN,
        FUNCTION_TOKEN,
        HASH_TOKEN,
        HEXADECIMAL_TOKEN,
        IDENTIFIER_TOKEN,
        INT_TOKEN,
        KEYWORD_TOKEN,
        LT_TOKEN,
        OPEN_CURLY_BRACKET_TOKEN,
        OPEN_PAREN_TOKEN,
        OPEN_SQUARE_BRACKET_TOKEN,
        SEMICOLON_TOKEN,
        STRING_INTERPOLATION_IDENTIFIER_TOKEN,
        STRING_INTERPOLATION_TOKEN,
        STRING_TOKEN;
import 'block_kind.dart';
import 'formal_parameter_kind.dart';
import 'forwarding_listener.dart';
import 'identifier_context.dart';
import 'listener.dart';
import 'literal_entry_info.dart';
import 'loop_state.dart';
import 'member_kind.dart';
import 'modifier_context.dart';
import 'token_stream_rewriter.dart';
import 'type_info.dart';
import 'util.dart';

/// An event generating parser of Dart programs. This parser expects all tokens
/// in a linked list (aka a token stream).
///
/// The class [Scanner] is used to generate a token stream. See the file
/// [scanner.dart](../scanner.dart).
///
/// Subclasses of the class [Listener] are used to listen to events.
///
/// Most methods of this class belong in one of four major categories: parse
/// methods, peek methods, ensure methods, and skip methods.
///
/// Parse methods all have the prefix `parse`, generate events
/// (by calling methods on [listener]), and return the next token to parse.
/// Some exceptions to this last point are methods such as [parseFunctionBody]
/// and [parseClassOrMixinOrExtensionBody] which return the last token parsed
/// rather than the next token to be parsed.
/// Parse methods are generally named `parseGrammarProductionSuffix`.
/// The suffix can be one of `opt`, or `star`.
/// `opt` means zero or one matches, `star` means zero or more matches.
/// For example, [parseMetadataStar] corresponds to this grammar snippet:
/// `metadata*`, and [parseArgumentsOpt] corresponds to: `arguments?`.
///
/// Peek methods all have the prefix `peek`, do not generate events
/// (except for errors) and may return null.
///
/// Ensure methods all have the prefix `ensure` and may generate events.
/// They return the current token, or insert and return a synthetic token
/// if the current token does not match. For example,
/// [ensureSemicolon] returns the current token if the current token is a
/// semicolon, otherwise inserts a synthetic semicolon in the token stream
/// before the current token and then returns that new synthetic token.
///
/// Skip methods are like parse methods, but all have the prefix `skip`
/// and skip over some parts of the file being parsed.
/// Typically, skip methods generate an event for the structure being skipped,
/// but not for its substructures.
///
/// ## Current Token
///
/// The current token is always to be found in a formal parameter named
/// `token`. This parameter should be the first as this increases the chance
/// that a compiler will place it in a register.
///
/// ## Implementation Notes
///
/// The parser assumes that keywords, built-in identifiers, and other special
/// words (pseudo-keywords) are all canonicalized. To extend the parser to
/// recognize a new identifier, one should modify
/// [keyword.dart](../scanner/keyword.dart) and ensure the identifier is added
/// to the keyword table.
///
/// As a consequence of this, one should not use `==` to compare strings in the
/// parser. One should favor the methods [optional] and [expect] to recognize
/// keywords or identifiers. In some cases, it's possible to compare a token's
/// `stringValue` using [identical], but normally [optional] will suffice.
///
/// Historically, we over-used identical, and when identical is used on objects
/// other than strings, it can often be replaced by `==`.
///
/// ## Flexibility, Extensibility, and Specification
///
/// The parser is designed to be flexible and extensible. Its methods are
/// designed to be overridden in subclasses, so it can be extended to handle
/// unspecified language extension or experiments while everything in this file
/// attempts to follow the specification (unless when it interferes with error
/// recovery).
///
/// We achieve flexibility, extensible, and specification compliance by
/// following a few rules-of-thumb:
///
/// 1. All methods in the parser should be public.
///
/// 2. The methods follow the specified grammar, and do not implement custom
/// extensions, for example, `native`.
///
/// 3. The parser doesn't rewrite the token stream (when dealing with `>>`).
///
/// ### Implementing Extensions
///
/// For various reasons, some Dart language implementations have used
/// custom/unspecified extensions to the Dart grammar. Examples of this
/// includes diet parsing, patch files, `native` keyword, and generic
/// comments. This class isn't supposed to implement any of these
/// features. Instead it provides hooks for those extensions to be implemented
/// in subclasses or listeners. Let's examine how diet parsing and `native`
/// keyword is currently supported by Fasta.
///
/// #### Legacy Implementation of `native` Keyword
///
/// TODO(ahe,danrubel): Remove this section.
///
/// Both dart2js and the Dart VM have used the `native` keyword to mark methods
/// that couldn't be implemented in the Dart language and needed to be
/// implemented in JavaScript or C++, respectively. An example of the syntax
/// extension used by the Dart VM is:
///
///     nativeFunction() native "NativeFunction";
///
/// When attempting to parse this function, the parser eventually calls
/// [parseFunctionBody]. This method will report an unrecoverable error to the
/// listener with the code [fasta.messageExpectedFunctionBody]. The listener can
/// then look at the error code and the token and use the methods in
/// [native_support.dart](native_support.dart) to parse the native syntax.
///
/// #### Implementation of Diet Parsing
///
/// We call it _diet_ _parsing_ when the parser skips parts of a file. Both
/// dart2js and the Dart VM have been relying on this from early on as it allows
/// them to more quickly compile small programs that use small parts of big
/// libraries. It's also become an integrated part of how Fasta builds up
/// outlines before starting to parse method bodies.
///
/// When looking through this parser, you'll find a number of unused methods
/// starting with `skip`. These methods are only used by subclasses, such as
/// [ClassMemberParser](class_member_parser.dart) and
/// [TopLevelParser](top_level_parser.dart). These methods violate the
/// principle above about following the specified grammar, and originally lived
/// in subclasses. However, we realized that these methods were so widely used
/// and hard to maintain in subclasses, that it made sense to move them here.
///
/// ### Specification and Error Recovery
///
/// To improve error recovery, the parser will inform the listener of
/// recoverable errors and continue to parse.  An example of a recoverable
/// error is:
///
///     Error: Asynchronous for-loop can only be used in 'async' or 'async*'...
///     main() { await for (var x in []) {} }
///              ^^^^^
///
/// ### Legacy Error Recovery
///
/// What's described below will be phased out in preference of the parser
/// reporting and recovering from syntax errors. The motivation for this is
/// that we have multiple listeners that use the parser, and this will ensure
/// consistency.
///
/// For unrecoverable errors, the parser will ask the listener for help to
/// recover from the error. We haven't made much progress on these kinds of
/// errors, so in most cases, the parser aborts by skipping to the end of file.
///
/// Historically, this parser has been rather lax in what it allows, and
/// deferred the enforcement of some syntactical rules to subsequent phases. It
/// doesn't matter how we got there, only that we've identified that it's
/// easier if the parser reports as many errors it can, but informs the
/// listener if the error is recoverable or not.
class Parser {
  Listener listener;

  Uri? get uri => listener.uri;

  bool mayParseFunctionExpressions = true;

  // TODO(danrubel): The [loopState] and associated functionality in the
  // [Parser] duplicates work that the resolver needs to do when resolving
  // break/continue targets. Long term, this state and functionality will be
  // removed from the [Parser] class and the resolver will be responsible
  // for generating all break/continue error messages.

  /// Represents parser state: whether parsing outside a loop,
  /// inside a loop, or inside a switch. This is used to determine whether
  /// break and continue statements are allowed.
  LoopState loopState = LoopState.OutsideLoop;

  /// A rewriter for inserting synthetic tokens.
  /// Access using [rewriter] for lazy initialization.
  TokenStreamRewriter? cachedRewriter;

  TokenStreamRewriter get rewriter {
    return cachedRewriter ??= new TokenStreamRewriterImpl();
  }

  /// If `true`, syntax like `foo<bar>.baz()` is parsed like an implicit
  /// creation expression. Otherwise it is parsed as a explicit instantiation
  /// followed by an invocation.
  ///
  /// With the constructor-tearoffs experiment, such syntax can lead to a valid
  /// expression that is _not_ an implicit creation expression, and the parser
  /// should therefore not special case the syntax but instead let listeners
  /// resolve the expression by the seen selectors.
  ///
  /// Use this flag to test that the implementation doesn't need the special
  /// casing.
  // TODO(johnniwinther): Remove this when both analyzer and CFE can parse the
  // implicit create expression without the special casing.
  final bool useImplicitCreationExpression;

  Parser(this.listener,
      {this.useImplicitCreationExpression:
          true}); // ignore:unnecessary_null_comparison

  bool get isBreakAllowed => loopState != LoopState.OutsideLoop;

  bool get isContinueAllowed => loopState == LoopState.InsideLoop;

  bool get isContinueWithLabelAllowed => loopState != LoopState.OutsideLoop;

  /// Parse a compilation unit.
  ///
  /// This method is only invoked from outside the parser. As a result, this
  /// method takes the next token to be consumed rather than the last consumed
  /// token and returns the token after the last consumed token rather than the
  /// last consumed token.
  ///
  /// ```
  /// libraryDefinition:
  ///   scriptTag?
  ///   libraryName?
  ///   importOrExport*
  ///   partDirective*
  ///   topLevelDefinition*
  /// ;
  ///
  /// partDeclaration:
  ///   partHeader topLevelDefinition*
  /// ;
  /// ```
  Token parseUnit(Token token) {
    // Skip over error tokens and report them at the end
    // so that the parser has the chance to adjust the error location.
    Token errorToken = token;
    token = skipErrorTokens(errorToken);

    listener.beginCompilationUnit(token);
    int count = 0;
    token = syntheticPreviousToken(token);

    while (!token.next!.isEof) {
      final Token start = token.next!;
      token = parseTopLevelDeclarationImpl(token);
      listener.endTopLevelDeclaration(token.next!);
      count++;
      if (start == token.next!) {
        // Recovery:
        // If progress has not been made reaching the end of the token stream,
        // then report an error and skip the current token.
        // token = token.next!;
        // token = parsePrimary(token, IdentifierContext.expression);
        token = parseExpression(token);
        // reportRecoverableErrorWithToken(
        //     token, codes.templateExpectedDeclaration);
        // listener.handleInvalidTopLevelDeclaration(token);
        // listener.endTopLevelDeclaration(token.next!);
        count++;
      }
    }
    token = token.next!;
    reportAllErrorTokens(errorToken);
    listener.endCompilationUnit(count, token);
    // Clear fields that could lead to memory leak.
    cachedRewriter = null;
    return token;
  }

  /// Parse a top-level declaration.
  ///
  /// This method is only invoked from outside the parser. As a result, this
  /// method takes the next token to be consumed rather than the last consumed
  /// token and returns the token after the last consumed token rather than the
  /// last consumed token.
  Token parseTopLevelDeclaration(Token token) {
    token = parseTopLevelDeclarationImpl(syntheticPreviousToken(token)).next!;
    listener.endTopLevelDeclaration(token);
    return token;
  }

  /// ```
  /// topLevelDefinition:
  ///   classDefinition |
  ///   enumType |
  ///   typeAlias |
  ///   'external'? functionSignature ';' |
  ///   'external'? getterSignature ';' |
  ///   'external''? setterSignature ';' |
  ///   functionSignature functionBody |
  ///   returnType? 'get' identifier functionBody |
  ///   returnType? 'set' identifier formalParameterList functionBody |
  ///   ('final' | 'const') type? staticFinalDeclarationList ';' |
  ///   variableDeclaration ';'
  /// ;
  /// ```
  Token parseTopLevelDeclarationImpl(Token token) {
    Token next = token.next!;

    if (optional('var', next)) {
      return parseTopLevelMemberImpl(token);
    }
    // Recovery
    if (next.isOperator && optional('(', next.next!)) {
      // This appears to be a top level operator declaration, which is invalid.
      reportRecoverableError(next, codes.messageTopLevelOperator);
      // Insert a synthetic identifier
      // and continue parsing as a top level function.
      rewriter.insertSyntheticIdentifier(
          next, '#synthetic_function_${next.charOffset}');
      return parseTopLevelMemberImpl(next);
    }
    // Ignore any preceding modifiers and just report the unexpected token
    listener.beginTopLevelMember(next);
    return token;
  }

  /// Parse the modifiers before the `class` keyword.
  /// Return the first `abstract` modifier or `null` if not found.
  Token? parseClassDeclarationModifiers(Token start, Token keyword) {
    Token modifier = start.next!;
    while (modifier != keyword) {
      if (optional('abstract', modifier)) {
        parseTopLevelKeywordModifiers(modifier, keyword);
        return modifier;
      } else {
        // Recovery
        reportTopLevelModifierError(modifier, keyword);
      }
      modifier = modifier.next!;
    }
    return null;
  }

  /// Report errors on any modifiers before the specified keyword.
  void parseTopLevelKeywordModifiers(Token start, Token keyword) {
    Token modifier = start.next!;
    while (modifier != keyword) {
      // Recovery
      reportTopLevelModifierError(modifier, keyword);
      modifier = modifier.next!;
    }
  }

  // Report an error for the given modifier preceding a top level keyword
  // such as `import` or `class`.
  void reportTopLevelModifierError(Token modifier, Token afterModifiers) {
    if (optional('const', modifier) && optional('class', afterModifiers)) {
      reportRecoverableError(modifier, codes.messageConstClass);
    } else if (optional('external', modifier)) {
      if (optional('class', afterModifiers)) {
        reportRecoverableError(modifier, codes.messageExternalClass);
      } else if (optional('enum', afterModifiers)) {
        reportRecoverableError(modifier, codes.messageExternalEnum);
      } else if (optional('typedef', afterModifiers)) {
        reportRecoverableError(modifier, codes.messageExternalTypedef);
      } else {
        reportRecoverableErrorWithToken(
            modifier, codes.templateExtraneousModifier);
      }
    } else {
      reportRecoverableErrorWithToken(
          modifier, codes.templateExtraneousModifier);
    }
  }

  /// Parse any top-level declaration that begins with a keyword.
  /// [start] is the token before any modifiers preceding [keyword].
  Token parseTopLevelKeywordDeclaration(
      Token start, Token keyword, Token? macroToken) {
    final String? value = keyword.toString();

    // The remaining top level keywords are built-in keywords
    // and can be used in a top level declaration
    // as an identifier such as "abstract<T>() => 0;"
    // or as a prefix such as "abstract.A b() => 0;".
    String? nextValue = keyword.next!.toString();
    if (identical(nextValue, '(') || identical(nextValue, '.')) {
      return parseTopLevelMemberImpl(start);
    } else if (identical(nextValue, '<')) {
      return parseTopLevelMemberImpl(start);
    } else {
      parseTopLevelKeywordModifiers(start, keyword);
    }

    throw "Internal error: Unhandled top level keyword '$value'.";
  }

  /// ```
  /// dottedName:
  ///   identifier ('.' identifier)*
  /// ;
  /// ```
  Token parseDottedName(Token token) {
    token = ensureIdentifier(token, IdentifierContext.dottedName);
    Token firstIdentifier = token;
    int count = 1;
    while (optional('.', token.next!)) {
      token = ensureIdentifier(
          token.next!, IdentifierContext.dottedNameContinuation);
      count++;
    }
    listener.handleDottedName(count, firstIdentifier);
    return token;
  }

  /// ```
  /// combinators:
  ///   (hideCombinator | showCombinator)*
  /// ;
  /// ```
  Token parseCombinatorStar(Token token) {
    Token next = token.next!;
    listener.beginCombinators(next);
    int count = 0;
    listener.endCombinators(count);
    return token;
  }

  /// ```
  /// identifierList:
  ///   identifier (',' identifier)*
  /// ;
  /// ```
  Token parseIdentifierList(Token token) {
    token = ensureIdentifier(token, IdentifierContext.combinator);
    int count = 1;
    while (optional(',', token.next!)) {
      token = ensureIdentifier(token.next!, IdentifierContext.combinator);
      count++;
    }
    listener.handleIdentifierList(count);
    return token;
  }

  /// ```
  /// typeList:
  ///   type (',' type)*
  /// ;
  /// ```
  Token parseTypeList(Token token) {
    listener.beginTypeList(token.next!);
    token =
        computeType(token, /* required = */ true).ensureTypeOrVoid(token, this);
    int count = 1;
    while (optional(',', token.next!)) {
      token = computeType(token.next!, /* required = */ true)
          .ensureTypeOrVoid(token.next!, this);
      count++;
    }
    listener.endTypeList(count);
    return token;
  }

  /// Parse the formal parameters of a getter (which shouldn't have parameters)
  /// or function or method.
  Token parseGetterOrFormalParameters(
      Token token, Token name, bool isGetter, MemberKind kind) {
    Token next = token.next!;
    if (optional("(", next)) {
      if (isGetter) {
        reportRecoverableError(next, codes.messageGetterWithFormals);
      }
      token = parseFormalParameters(token, kind);
    } else if (isGetter) {
      listener.handleNoFormalParameters(next, kind);
    } else {
      // Recovery
      if (optional('operator', name)) {
        Token next = name.next!;
        if (next.isOperator) {
          name = next;
        } else if (isUnaryMinus(next)) {
          name = next.next!;
        }
      }
      reportRecoverableError(name, missingParameterMessage(kind));
      token = rewriter.insertParens(token, /* includeIdentifier = */ false);
      token = parseFormalParametersRest(token, kind);
    }
    return token;
  }

  Token parseFormalParametersOpt(Token token, MemberKind kind) {
    Token next = token.next!;
    if (optional('(', next)) {
      token = parseFormalParameters(token, kind);
    } else {
      listener.handleNoFormalParameters(next, kind);
    }
    return token;
  }

  Token skipFormalParameters(Token token, MemberKind kind) {
    return skipFormalParametersRest(token.next!, kind);
  }

  Token skipFormalParametersRest(Token token, MemberKind kind) {
    assert(optional('(', token));
    // TODO(ahe): Shouldn't this be `beginFormalParameters`?
    listener.beginOptionalFormalParameters(token);
    Token closeBrace = token.endGroup!;
    assert(optional(')', closeBrace));
    listener.endFormalParameters(/* count = */ 0, token, closeBrace, kind);
    return closeBrace;
  }

  /// Parses the formal parameter list of a function.
  ///
  /// If `kind == MemberKind.GeneralizedFunctionType`, then names may be
  /// omitted (except for named arguments). Otherwise, types may be omitted.
  Token parseFormalParametersRequiredOpt(Token token, MemberKind kind) {
    Token next = token.next!;
    if (!optional('(', next)) {
      reportRecoverableError(next, missingParameterMessage(kind));
      next = rewriter.insertParens(token, /* includeIdentifier = */ false);
    }
    return parseFormalParametersRest(next, kind);
  }

  /// Parses the formal parameter list of a function given that the left
  /// parenthesis is known to exist.
  ///
  /// If `kind == MemberKind.GeneralizedFunctionType`, then names may be
  /// omitted (except for named arguments). Otherwise, types may be omitted.
  Token parseFormalParameters(Token token, MemberKind kind) {
    return parseFormalParametersRest(token.next!, kind);
  }

  /// Parses the formal parameter list of a function given that the left
  /// parenthesis passed in as [token].
  ///
  /// If `kind == MemberKind.GeneralizedFunctionType`, then names may be
  /// omitted (except for named arguments). Otherwise, types may be omitted.
  Token parseFormalParametersRest(Token token, MemberKind kind) {
    Token begin = token;
    assert(optional('(', token));
    listener.beginFormalParameters(begin, kind);
    int parameterCount = 0;
    while (true) {
      Token next = token.next!;
      if (optional(')', next)) {
        token = next;
        break;
      }
      ++parameterCount;
      String? value = next.toString();
      if (identical(value, '[')) {
        token = parseOptionalPositionalParameters(token, kind);
        token = ensureCloseParen(token, begin);
        break;
      } else if (identical(value, '{')) {
        token = parseOptionalNamedParameters(token, kind);
        token = ensureCloseParen(token, begin);
        break;
      } else if (identical(value, '[]')) {
        // Recovery
        token = rewriteSquareBrackets(token);
        token = parseOptionalPositionalParameters(token, kind);
        token = ensureCloseParen(token, begin);
        break;
      }
      token = parseFormalParameter(token, FormalParameterKind.mandatory, kind);
      next = token.next!;
      if (!optional(',', next)) {
        Token next = token.next!;
        if (optional(')', next)) {
          token = next;
        } else {
          // Recovery
          if (next.kind == IDENTIFIER_TOKEN &&
              next.next!.kind == IDENTIFIER_TOKEN) {
            // Looks like a missing comma
            token = rewriteAndRecover(
                token,
                codes.templateExpectedButGot.withArguments(','),
                SyntheticToken(type: TokenType.COMMA, offset: next.charOffset));
            continue;
          } else {
            token = ensureCloseParen(token, begin);
          }
        }
        break;
      }
      token = next;
    }
    assert(optional(')', token));
    listener.endFormalParameters(parameterCount, begin, token, kind);
    return token;
  }

  /// Return the message that should be produced when the formal parameters are
  /// missing.
  codes.Message missingParameterMessage(MemberKind kind) {
    if (kind == MemberKind.FunctionTypeAlias) {
      return codes.messageMissingTypedefParameters;
    } else if (kind == MemberKind.NonStaticMethod ||
        kind == MemberKind.StaticMethod) {
      return codes.messageMissingMethodParameters;
    }
    return codes.messageMissingFunctionParameters;
  }

  /// ```
  /// normalFormalParameter:
  ///   functionFormalParameter |
  ///   fieldFormalParameter |
  ///   simpleFormalParameter
  /// ;
  ///
  /// functionFormalParameter:
  ///   metadata 'covariant'? returnType? identifier formalParameterList
  /// ;
  ///
  /// simpleFormalParameter:
  ///   metadata 'covariant'? finalConstVarOrType? identifier |
  /// ;
  ///
  /// fieldFormalParameter:
  ///   metadata finalConstVarOrType? 'this' '.' identifier formalParameterList?
  /// ;
  /// ```
  Token parseFormalParameter(
      Token token, FormalParameterKind parameterKind, MemberKind memberKind) {
    // ignore: unnecessary_null_comparison
    assert(parameterKind != null);

    Token next = token.next!;
    Token start = next;

    final bool inFunctionType =
        memberKind == MemberKind.GeneralizedFunctionType;

    Token? requiredToken;
    Token? covariantToken;
    Token? varFinalOrConst;

    listener.beginFormalParameter(
        start, memberKind, requiredToken, covariantToken, varFinalOrConst);

    // Type is required in a generalized function type, but optional otherwise.
    final Token beforeType = token;
    TypeInfo typeInfo = computeType(
      token,
      inFunctionType,
      /* inDeclaration = */ false,
      /* acceptKeywordForSimpleType = */ true,
    );
    token = typeInfo.skipType(token);
    next = token.next!;
    if (typeInfo == noType &&
        (optional('.', next) ||
            (next.isIdentifier && optional('.', next.next!)))) {
      // Recovery: Malformed type reference.
      typeInfo = computeType(beforeType, /* required = */ true);
      token = typeInfo.skipType(beforeType);
      next = token.next!;
    }

    final bool isNamedParameter =
        parameterKind == FormalParameterKind.optionalNamed;

    Token? thisKeyword;
    Token? superKeyword;
    Token? periodAfterThisOrSuper;
    IdentifierContext nameContext =
        IdentifierContext.formalParameterDeclaration;

    if (!inFunctionType &&
        (optional('this', next) || optional('super', next))) {
      Token originalToken = token;
      if (optional('this', next)) {
        thisKeyword = token = next;
      } else {
        superKeyword = token = next;
      }
      next = token.next!;
      if (!optional('.', next)) {
        if (isOneOf(next, okNextValueInFormalParameter)) {
          // Recover by not parsing as 'this' --- an error will be given
          // later that it's not an allowed identifier.
          token = originalToken;
          next = token.next!;
          thisKeyword = superKeyword = null;
        } else {
          // Recover from a missing period by inserting one.
          next = rewriteAndRecover(
              token,
              codes.templateExpectedButGot.withArguments('.'),
              SyntheticToken(type: TokenType.PERIOD, offset: next.charOffset));
          // These 3 lines are duplicated here and below.
          periodAfterThisOrSuper = token = next;
          next = token.next!;
          nameContext = IdentifierContext.fieldInitializer;
        }
      } else {
        // These 3 lines are duplicated here and above.
        periodAfterThisOrSuper = token = next;
        next = token.next!;
        nameContext = IdentifierContext.fieldInitializer;
      }
    }

    if (next.isIdentifier) {
      token = next;
      next = token.next!;
    }
    Token? beforeInlineFunctionType;
    TypeParamOrArgInfo typeParam = noTypeParamOrArg;
    if (optional("<", next)) {
      typeParam = computeTypeParamOrArg(token);
      if (typeParam != noTypeParamOrArg) {
        Token closer = typeParam.skip(token);
        if (optional("(", closer.next!)) {
          if (varFinalOrConst != null) {
            reportRecoverableError(
                varFinalOrConst, codes.messageFunctionTypedParameterVar);
          }
          beforeInlineFunctionType = token;
          token = closer.next!.endGroup!;
          next = token.next!;
        }
      }
    } else if (optional("(", next)) {
      if (varFinalOrConst != null) {
        reportRecoverableError(
            varFinalOrConst, codes.messageFunctionTypedParameterVar);
      }
      beforeInlineFunctionType = token;
      token = next.endGroup!;
      next = token.next!;
    }
    if (typeInfo != noType &&
        varFinalOrConst != null &&
        optional('var', varFinalOrConst)) {
      reportRecoverableError(varFinalOrConst, codes.messageTypeAfterVar);
    }

    Token? endInlineFunctionType;
    if (beforeInlineFunctionType != null) {
      endInlineFunctionType =
          typeParam.parseVariables(beforeInlineFunctionType, this);
      listener
          .beginFunctionTypedFormalParameter(beforeInlineFunctionType.next!);
      token = typeInfo.parseType(beforeType, this);
      endInlineFunctionType = parseFormalParametersRequiredOpt(
          endInlineFunctionType, MemberKind.FunctionTypedParameter);
      Token? question;
      if (optional('?', endInlineFunctionType.next!)) {
        question = endInlineFunctionType = endInlineFunctionType.next!;
      }
      listener.endFunctionTypedFormalParameter(
          beforeInlineFunctionType, question);

      // Generalized function types don't allow inline function types.
      // The following isn't allowed:
      //    int Function(int bar(String x)).
      if (inFunctionType) {
        reportRecoverableError(beforeInlineFunctionType.next!,
            codes.messageInvalidInlineFunctionType);
      }
    } else if (inFunctionType) {
      token = typeInfo.ensureTypeOrVoid(beforeType, this);
    } else {
      token = typeInfo.parseType(beforeType, this);
    }

    Token nameToken;
    if (periodAfterThisOrSuper != null) {
      token = periodAfterThisOrSuper;
    }
    next = token.next!;
    if (inFunctionType &&
        !isNamedParameter &&
        !next.isKeywordOrIdentifier &&
        beforeInlineFunctionType == null) {
      nameToken = token.next!;
      listener.handleNoName(nameToken);
    } else {
      nameToken = token = ensureIdentifier(token, nameContext);
      if (isNamedParameter && nameToken.lexeme.startsWith("_")) {
        reportRecoverableError(nameToken, codes.messagePrivateNamedParameter);
      }
    }
    if (endInlineFunctionType != null) {
      token = endInlineFunctionType;
    }
    next = token.next!;

    String? value = next.toString();
    Token? initializerStart, initializerEnd;
    if ((identical('=', value)) || (identical(':', value))) {
      Token equal = next;
      initializerStart = equal.next!;
      listener.beginFormalParameterDefaultValueExpression();
      token = initializerEnd = parseExpression(equal);
      next = token.next!;
      listener.endFormalParameterDefaultValueExpression();
      // TODO(danrubel): Consider removing the last parameter from the
      // handleValuedFormalParameter event... it appears to be unused.
      listener.handleValuedFormalParameter(equal, next);
      if (isMandatoryFormalParameterKind(parameterKind)) {
        reportRecoverableError(
            equal, codes.messageRequiredParameterWithDefault);
      } else if (isOptionalPositionalFormalParameterKind(parameterKind) &&
          identical(':', value)) {
        reportRecoverableError(
            equal, codes.messagePositionalParameterWithEquals);
      } else if (inFunctionType ||
          memberKind == MemberKind.FunctionTypeAlias ||
          memberKind == MemberKind.FunctionTypedParameter) {
        reportRecoverableError(equal, codes.messageFunctionTypeDefaultValue);
      }
    } else {
      listener.handleFormalParameterWithoutValue(next);
    }
    listener.endFormalParameter(
        nameToken, initializerStart, initializerEnd, parameterKind, memberKind);
    return token;
  }

  /// ```
  /// defaultFormalParameter:
  ///   normalFormalParameter ('=' expression)?
  /// ;
  /// ```
  Token parseOptionalPositionalParameters(Token token, MemberKind kind) {
    Token begin = token = token.next!;
    assert(optional('[', token));
    listener.beginOptionalFormalParameters(begin);
    int parameterCount = 0;
    while (true) {
      Token next = token.next!;
      if (optional(']', next)) {
        break;
      }
      token = parseFormalParameter(
          token, FormalParameterKind.optionalPositional, kind);
      next = token.next!;
      ++parameterCount;
      if (!optional(',', next)) {
        if (!optional(']', next)) {
          // Recovery
          reportRecoverableError(
              next, codes.templateExpectedButGot.withArguments(']'));
          // Scanner guarantees a closing bracket.
          next = begin.endGroup!;
          while (token.next != next) {
            token = token.next!;
          }
        }
        break;
      }
      token = next;
    }
    if (parameterCount == 0) {
      rewriteAndRecover(
          token,
          codes.messageEmptyOptionalParameterList,
          SyntheticStringToken(
            type: TokenType.IDENTIFIER,
            value: '',
            offset: token.next!.charOffset,
          ));
      token = parseFormalParameter(
          token, FormalParameterKind.optionalPositional, kind);
      ++parameterCount;
    }
    token = token.next!;
    assert(optional(']', token));
    listener.endOptionalFormalParameters(parameterCount, begin, token);
    return token;
  }

  /// ```
  /// defaultNamedParameter:
  ///   normalFormalParameter ('=' expression)? |
  ///   normalFormalParameter (':' expression)?
  /// ;
  /// ```
  Token parseOptionalNamedParameters(Token token, MemberKind kind) {
    Token begin = token = token.next!;
    assert(optional('{', token));
    listener.beginOptionalFormalParameters(begin);
    int parameterCount = 0;
    while (true) {
      Token next = token.next!;
      if (optional('}', next)) {
        break;
      }
      token =
          parseFormalParameter(token, FormalParameterKind.optionalNamed, kind);
      next = token.next!;
      ++parameterCount;
      if (!optional(',', next)) {
        if (!optional('}', next)) {
          // Recovery
          reportRecoverableError(
              next, codes.templateExpectedButGot.withArguments('}'));
          // Scanner guarantees a closing bracket.
          next = begin.endGroup!;
          while (token.next != next) {
            token = token.next!;
          }
        }
        break;
      }
      token = next;
    }
    if (parameterCount == 0) {
      rewriteAndRecover(
          token,
          codes.messageEmptyNamedParameterList,
          SyntheticStringToken(
            type: TokenType.IDENTIFIER,
            value: '',
            offset: token.next!.charOffset,
          ));
      token =
          parseFormalParameter(token, FormalParameterKind.optionalNamed, kind);
      ++parameterCount;
    }
    token = token.next!;
    assert(optional('}', token));
    listener.endOptionalFormalParameters(parameterCount, begin, token);
    return token;
  }

  Token parseProgram(Token token) {
    // Skip over error tokens and report them at the end
    // so that the parser has the chance to adjust the error location.
    Token errorToken = token;
    token = skipErrorTokens(errorToken);

    listener.beginProgram(token);
    token = syntheticPreviousToken(token);

    while (!token.next!.isEof) {
      token = parseExpression(token);
    }
    token = token.next!;
    reportAllErrorTokens(errorToken);
    listener.endProgram(token);
    // Clear fields that could lead to memory leak.
    cachedRewriter = null;
    return token;
  }

  /// ```
  /// qualified:
  ///   identifier qualifiedRest*
  /// ;
  /// ```
  Token parseQualified(Token token, IdentifierContext context,
      IdentifierContext continuationContext) {
    token = ensureIdentifier(token, context);
    while (optional('.', token.next!)) {
      token = parseQualifiedRest(token, continuationContext);
    }
    return token;
  }

  /// ```
  /// qualifiedRestOpt:
  ///   qualifiedRest?
  /// ;
  /// ```
  Token parseQualifiedRestOpt(
      Token token, IdentifierContext continuationContext) {
    if (optional('.', token.next!)) {
      return parseQualifiedRest(token, continuationContext);
    } else {
      return token;
    }
  }

  /// ```
  /// qualifiedRest:
  ///   '.' identifier
  /// ;
  /// ```
  Token parseQualifiedRest(Token token, IdentifierContext context) {
    token = token.next!;
    assert(optional('.', token));
    Token period = token;
    token = ensureIdentifier(token, context);
    listener.handleQualified(period);
    return token;
  }

  Token skipBlock(Token token) {
    // The scanner ensures that `{` always has a closing `}`.
    return ensureBlock(
            token, /* template = */ null, /* missingBlockName = */ null)
        .endGroup!;
  }

  Token parseStringPart(Token token) {
    Token next = token.next!;
    if (next.kind != STRING_TOKEN) {
      reportRecoverableErrorWithToken(next, codes.templateExpectedString);
      next = rewriter.insertToken(
          token,
          SyntheticStringToken(
              type: TokenType.STRING, value: '', offset: next.charOffset));
    }
    listener.handleStringPart(next);
    return next;
  }

  /// Insert a synthetic identifier after the given [token] and create an error
  /// message based on the given [context]. Return the synthetic identifier that
  /// was inserted.
  Token insertSyntheticIdentifier(Token token, IdentifierContext context,
      {codes.Message? message, Token? messageOnToken}) {
    Token next = token.next!;
    reportRecoverableError(messageOnToken ?? next,
        message ?? context.recoveryTemplate.withArguments(next));
    return rewriter.insertSyntheticIdentifier(token);
  }

  /// Parse a simple identifier at the given [token], and return the identifier
  /// that was parsed.
  ///
  /// If the token is not an identifier, or is not appropriate for use as an
  /// identifier in the given [context], create a synthetic identifier, report
  /// an error, and return the synthetic identifier.
  Token ensureIdentifier(Token token, IdentifierContext context) {
    // ignore: unnecessary_null_comparison
    assert(context != null);
    Token identifier = token.next!;
    if (identifier.kind != IDENTIFIER_TOKEN) {
      identifier = context.ensureIdentifier(token, this);
      // ignore: unnecessary_null_comparison
      assert(identifier != null);
      assert(identifier.isKeywordOrIdentifier);
    }
    listener.handleIdentifier(identifier, context);
    return identifier;
  }

  /// Checks whether the next token is (directly) an identifier. If this returns
  /// true a call to [ensureIdentifier] will return the next token.
  bool isNextIdentifier(Token token) => token.next?.kind == IDENTIFIER_TOKEN;

  /// Parse a simple identifier at the given [token], and return the identifier
  /// that was parsed.
  ///
  /// If the token is not an identifier, or is not appropriate for use as an
  /// identifier in the given [context], create a synthetic identifier, report
  /// an error, and return the synthetic identifier.
  /// [isRecovered] is passed to [context] which - if true - allows implementers
  /// to use the token as an identifier, even if it isn't a valid identifier.
  Token ensureIdentifierPotentiallyRecovered(
      Token token, IdentifierContext context, bool isRecovered) {
    // ignore: unnecessary_null_comparison
    assert(context != null);
    Token identifier = token.next!;
    if (identifier.kind != IDENTIFIER_TOKEN) {
      identifier = context.ensureIdentifierPotentiallyRecovered(
          token, this, isRecovered);
      // ignore: unnecessary_null_comparison
      assert(identifier != null);
      assert(identifier.isKeywordOrIdentifier);
    }
    listener.handleIdentifier(identifier, context);
    return identifier;
  }

  bool notEofOrValue(String value, Token token) {
    return !identical(token.kind, EOF_TOKEN) &&
        !identical(value, token.toString());
  }

  Token parseTypeVariablesOpt(Token token) {
    return computeTypeParamOrArg(token, /* inDeclaration = */ true)
        .parseVariables(token, this);
  }

  /// Parse a top level field or function.
  ///
  /// This method is only invoked from outside the parser. As a result, this
  /// method takes the next token to be consumed rather than the last consumed
  /// token and returns the token after the last consumed token rather than the
  /// last consumed token.
  Token parseTopLevelMember(Token token) {
    return parseTopLevelMemberImpl(token).next!;
  }

  Token parseTopLevelMemberImpl(Token token) {
    Token beforeStart = token;
    Token next = token.next!;
    listener.beginTopLevelMember(next);

    Token? varFinalOrConst;

    if (optional('var', next)) {
      varFinalOrConst = token = next;
      next = token.next!;
    }

    // Recovery
    if (varFinalOrConst == null) {
      ModifierRecoveryContext context = ModifierRecoveryContext(this)
        ..varFinalOrConst = varFinalOrConst;

      token = context.parseTopLevelModifiers(token);
      next = token.next!;

      varFinalOrConst = context.varFinalOrConst;
    }

    Token beforeType = token;
    TypeInfo typeInfo =
        computeType(token, /* required = */ false, /* inDeclaration = */ true);
    token = typeInfo.skipType(token);
    next = token.next!;

    String? value = next.toString();

    bool nameIsRecovered = false;

    // Recovery: If the code is
    // <return type>? <reserved word> <token indicating method or field>
    // take the reserved keyword as the name.
    if (typeInfo == noType &&
        varFinalOrConst == null &&
        isReservedKeyword(next.next!) &&
        indicatesMethodOrField(next.next!.next!)) {
      // Recovery: Use the reserved keyword despite that not being legal.
      typeInfo = computeType(
        token,
        /* required = */ true,
        /* inDeclaration = */ true,
      );
      token = typeInfo.skipType(token);
      next = token.next!;
      nameIsRecovered = true;
    }

    if (next.type != TokenType.IDENTIFIER) {
      value = next.toString();
      if (!next.isIdentifier) {
        // Recovery
        if (next.isKeyword) {
          // Fall through to parse the keyword as the identifier.
          // ensureIdentifier will report the error.
        } else if (token == beforeStart) {
          // Ensure we make progress.
          return parseInvalidTopLevelDeclaration(token);
        } else {
          // Looks like a declaration missing an identifier.
          // Insert synthetic identifier and fall through.
          insertSyntheticIdentifier(token, IdentifierContext.methodDeclaration);
          next = token.next!;
        }
      }
    }
    // At this point, `token` is beforeName.

    // Recovery: Inserted ! after method name.
    if (optional('!', next.next!)) {
      next = next.next!;
    }

    next = next.next!;
    value = next.toString();
    if (identical(value, '(') ||
        identical(value, '{') ||
        identical(value, '<') ||
        identical(value, '.') ||
        identical(value, '=>')) {
      if (varFinalOrConst != null) {
        if (optional('var', varFinalOrConst)) {
          reportRecoverableError(varFinalOrConst, codes.messageVarReturnType);
        } else {
          reportRecoverableErrorWithToken(
              varFinalOrConst, codes.templateExtraneousModifier);
        }
      }
      return parseTopLevelMethod(
          beforeStart, beforeType, typeInfo, token.next!, nameIsRecovered);
    }

    return parseFields(beforeStart, varFinalOrConst, beforeType, typeInfo,
        token.next!, /* enclosingDeclarationName = */ null, nameIsRecovered);
  }

  Token parseFields(
      Token beforeStart,
      Token? varFinalOrConst,
      Token beforeType,
      TypeInfo typeInfo,
      Token name,
      String? enclosingDeclarationName,
      bool nameIsRecovered) {
    listener.beginFields(varFinalOrConst, beforeStart);

    if (typeInfo == noType) {
      if (varFinalOrConst == null) {
        reportRecoverableError(name, codes.messageMissingConstFinalVarOrType);
      }
    } else {
      if (varFinalOrConst != null && optional('var', varFinalOrConst)) {
        reportRecoverableError(varFinalOrConst, codes.messageTypeAfterVar);
      }
    }

    Token token = typeInfo.parseType(beforeType, this);
    assert(token.next == name || token.next!.isEof);

    IdentifierContext context = IdentifierContext.topLevelVariableDeclaration;
    Token firstName = name = ensureIdentifierPotentiallyRecovered(
        token, context, /* isRecovered = */ nameIsRecovered);

    int fieldCount = 1;

    while (optional(',', token.next!)) {
      name = ensureIdentifier(token.next!, context);

      ++fieldCount;
    }
    Token semicolon = token.next!;
    if (optional(';', semicolon)) {
      token = semicolon;
    } else {
      // Recovery
      token = ensureSemicolon(token);
    }

    listener.endTopLevelFields(
        varFinalOrConst, fieldCount, beforeStart.next!, token);

    return token;
  }

  Token parseTopLevelMethod(Token beforeStart, Token beforeType,
      TypeInfo typeInfo, Token name, bool nameIsRecovered) {
    listener.beginTopLevelMethod(beforeStart, null);

    Token token = typeInfo.parseType(beforeType, this);
    assert(token.next == name || token.next!.isEof);
    name = ensureIdentifierPotentiallyRecovered(
        token,
        IdentifierContext.topLevelFunctionDeclaration,
        /* isRecovered = */ nameIsRecovered);

    bool isGetter = false;

    token = parseMethodTypeVar(name);

    token = parseGetterOrFormalParameters(
        token, name, isGetter, MemberKind.TopLevelMethod);

    token = parseFunctionBody(
      token,
      /* ofFunctionExpression = */ false,
    );

    listener.endTopLevelMethod(beforeStart.next!, token);
    return token;
  }

  Token parseMethodTypeVar(Token name) {
    if (optional('!', name.next!)) {
      // Recovery
      name = name.next!;
      reportRecoverableErrorWithToken(name, codes.templateUnexpectedToken);
    }
    if (!optional('<', name.next!)) {
      return noTypeParamOrArg.parseVariables(name, this);
    }
    TypeParamOrArgInfo typeVar =
        computeTypeParamOrArg(name, /* inDeclaration = */ true);
    Token token = typeVar.parseVariables(name, this);
    if (optional('=', token.next!)) {
      // Recovery
      token = token.next!;
      reportRecoverableErrorWithToken(token, codes.templateUnexpectedToken);
    }
    return token;
  }

  Token parseVariableInitializerOpt(Token token) {
    if (optional('=', token.next!)) {
      Token assignment = token.next!;
      listener.beginVariableInitializer(assignment);
      token = parseExpression(assignment);
      listener.endVariableInitializer(assignment);
    } else {
      listener.handleNoVariableInitializer(token);
    }
    return token;
  }

  /// If the next token is an opening curly brace, return it. Otherwise, use the
  /// given [template] or [missingBlockName] to report an error, insert an
  /// opening and a closing curly brace, and return the newly inserted opening
  /// curly brace. If  [template] and [missingBlockName] are `null`, then use
  /// a default error message instead.
  Token ensureBlock(
      Token token,
      codes.Template<codes.Message Function(Token token)>? template,
      String? missingBlockName) {
    Token next = token.next!;
    if (optional('{', next)) return next;
    if (template == null) {
      if (missingBlockName == null) {
        // TODO(danrubel): rename ExpectedButGot to ExpectedBefore
        reportRecoverableError(
            next, codes.templateExpectedButGot.withArguments('{'));
      } else {
        // TODO(danrubel): rename ExpectedClassOrMixinBody
        //  to ExpectedDeclarationOrClauseBody
        reportRecoverableError(
            token,
            codes.templateExpectedClassOrMixinBody
                .withArguments(missingBlockName));
      }
    } else {
      reportRecoverableError(next, template.withArguments(next));
    }
    return insertBlock(token);
  }

  Token insertBlock(Token token) {
    Token next = token.next!;
    BeginToken beginGroup = rewriter.insertToken(
        token,
        SyntheticBeginToken(
            type: TokenType.OPEN_CURLY_BRACKET,
            offset: next.offset)) as BeginToken;
    Token endGroup = rewriter.insertToken(
        beginGroup,
        SyntheticToken(
            type: TokenType.CLOSE_CURLY_BRACKET, offset: next.offset));
    beginGroup.endGroup = endGroup;
    return beginGroup;
  }

  /// If the next token is a closing parenthesis, return it.
  /// Otherwise, report an error and return the closing parenthesis
  /// associated with the specified open parenthesis.
  Token ensureCloseParen(Token token, Token openParen) {
    Token next = token.next!;
    if (optional(')', next)) {
      return next;
    }
    if (openParen.endGroup!.isSynthetic) {
      // Scanner has already reported a missing `)` error,
      // but placed the `)` in the wrong location, so move it.
      return rewriter.moveSynthetic(token, openParen.endGroup!);
    }

    // TODO(danrubel): Pass in context for better error message.
    reportRecoverableError(
        next, codes.templateExpectedButGot.withArguments(')'));

    // Scanner guarantees a closing parenthesis
    // TODO(danrubel): Improve recovery by having callers parse tokens
    // between `token` and `openParen.endGroup`.
    return openParen.endGroup!;
  }

  /// If the next token is a colon, return it. Otherwise, report an
  /// error, insert a synthetic colon, and return the inserted colon.
  Token ensureColon(Token token) {
    Token next = token.next!;
    if (optional(':', next)) return next;
    codes.Message message = codes.templateExpectedButGot.withArguments(':');
    Token newToken =
        SyntheticToken(type: TokenType.COLON, offset: next.charOffset);
    return rewriteAndRecover(token, message, newToken);
  }

  /// If the token after [token] is a not literal string,
  /// then insert a synthetic literal string.
  /// Call `parseLiteralString` and return the result.
  Token ensureLiteralString(Token token) {
    Token next = token.next!;
    if (!identical(next.kind, STRING_TOKEN)) {
      codes.Message message = codes.templateExpectedString.withArguments(next);
      Token newToken = SyntheticStringToken(
          type: TokenType.STRING, value: '""', offset: next.charOffset);
      rewriteAndRecover(token, message, newToken);
    }
    return parseLiteralString(token);
  }

  /// If the token after [token] is a semi-colon, return it.
  /// Otherwise, report an error, insert a synthetic semi-colon,
  /// and return the inserted semi-colon.
  Token ensureSemicolon(Token token) {
    // TODO(danrubel): Once all expect(';'...) call sites have been converted
    // to use this method, remove similar semicolon recovery code
    // from the handleError method in element_listener.dart.
    Token next = token.next!;
    if (optional(';', next)) return next;

    // Find a token on the same line as where the ';' should be inserted.
    // Reporting the error on this token makes it easier
    // for users to understand and fix the error.
    reportRecoverableError(findPreviousNonZeroLengthToken(token),
        codes.templateExpectedAfterButGot.withArguments(';'));
    return rewriter.insertSyntheticToken(token, TokenType.SEMICOLON);
  }

  /// Report an error at the token after [token] that has the given [message].
  /// Insert the [newToken] after [token] and return [newToken].
  Token rewriteAndRecover(Token token, codes.Message message, Token newToken) {
    reportRecoverableError(token.next!, message);
    return rewriter.insertToken(token, newToken);
  }

  /// Replace the token after [token] with `[` followed by `]`
  /// and return [token].
  Token rewriteSquareBrackets(Token token) {
    Token next = token.next!;
    assert(optional('[]', next));
    Token replacement;
    if (next.isSynthetic) {
      replacement = link(
          SyntheticBeginToken(
              type: TokenType.OPEN_SQUARE_BRACKET, offset: next.offset),
          SyntheticToken(
              type: TokenType.CLOSE_SQUARE_BRACKET, offset: next.offset));
    } else {
      replacement = link(
          BeginToken(type: TokenType.OPEN_SQUARE_BRACKET, offset: next.offset),
          SimpleToken(
              type: TokenType.CLOSE_SQUARE_BRACKET, offset: next.offset + 1));
    }
    rewriter.replaceTokenFollowing(token, replacement);
    return token;
  }

  /// Report the given token as unexpected and return the next token if the next
  /// token is one of the [expectedNext], otherwise just return the given token.
  Token skipUnexpectedTokenOpt(Token token, List<String> expectedNext) {
    Token next = token.next!;
    if (!next.isKeyword) {
      final String? nextValue = next.next!.toString();
      for (String expectedValue in expectedNext) {
        if (identical(nextValue, expectedValue)) {
          reportRecoverableErrorWithToken(next, codes.templateUnexpectedToken);
          return next;
        }
      }
    }
    return token;
  }

  bool isUnaryMinus(Token token) =>
      token.kind == IDENTIFIER_TOKEN &&
      token.lexeme == 'unary' &&
      optional('-', token.next!);

  bool isReservedKeyword(Token token) {
    if (!token.isKeyword) return false;
    return token.type.isReservedWord;
  }

  bool indicatesMethodOrField(Token token) {
    String? value = token.toString();
    if (identical(value, ';') ||
        identical(value, '=') ||
        identical(value, '(') ||
        identical(value, '{') ||
        identical(value, '=>') ||
        identical(value, '<')) {
      return true;
    }
    return false;
  }

  Token parseOperatorName(Token token) {
    Token beforeToken = token;
    token = token.next!;
    assert(optional('operator', token));
    Token next = token.next!;
    if (optional('(', next)) {
      return ensureIdentifier(beforeToken, IdentifierContext.operatorName);
    } else if (isUnaryMinus(next)) {
      // Recovery
      reportRecoverableErrorWithToken(next, codes.templateUnexpectedToken);
      next = next.next!;
      listener.handleOperatorName(token, next);
      return next;
    } else {
      // Recovery
      // Scanner reports an error for `===` and `!==`.
      if (next.type != TokenType.EQ_EQ_EQ &&
          next.type != TokenType.BANG_EQ_EQ) {
        // The user has specified an invalid operator name.
        // Report the error, accept the invalid operator name, and move on.
        reportRecoverableErrorWithToken(next, codes.templateInvalidOperator);
      }
      listener.handleInvalidOperatorName(token, next);
      return next;
    }
  }

  Token parseFunctionExpression(Token token) {
    Token beginToken = token.next!;
    listener.beginFunctionExpression(beginToken);
    token = parseFormalParametersRequiredOpt(token, MemberKind.Local);
    listener.endFunctionExpression(beginToken, token.next!);
    return token;
  }

  Token parseFunctionLiteral(
      Token start,
      Token beforeName,
      Token name,
      TypeInfo typeInfo,
      TypeParamOrArgInfo typeParam,
      IdentifierContext context) {
    Token formals = typeParam.parseVariables(name, this);
    listener.beginNamedFunctionExpression(start.next!);
    typeInfo.parseType(start, this);
    return parseNamedFunctionRest(
        beforeName, start.next!, formals, /* isFunctionExpression = */ true);
  }

  /// Parses the rest of a named function declaration starting from its [name]
  /// but then skips any type parameters and continue parsing from [formals]
  /// (the formal parameters).
  ///
  /// If [isFunctionExpression] is true, this method parses the rest of named
  /// function expression which isn't legal syntax in Dart.  Useful for
  /// recovering from Javascript code being pasted into a Dart program, as it
  /// will interpret `function foo() {}` as a named function expression with
  /// return type `function` and name `foo`.
  ///
  /// Precondition: the parser has previously generated these events:
  ///
  /// - Type variables.
  /// - `beginLocalFunctionDeclaration` if [isFunctionExpression] is false,
  ///   otherwise `beginNamedFunctionExpression`.
  /// - Return type.
  Token parseNamedFunctionRest(
      Token beforeName, Token begin, Token formals, bool isFunctionExpression) {
    Token token = beforeName.next!;
    listener.beginFunctionName(token);
    token =
        ensureIdentifier(beforeName, IdentifierContext.localFunctionDeclaration)
            .next!;
    if (isFunctionExpression) {
      reportRecoverableError(
          beforeName.next!, codes.messageNamedFunctionExpression);
    }
    listener.endFunctionName(begin, token);
    token = parseFormalParametersRequiredOpt(formals, MemberKind.Local);
    if (isFunctionExpression) {
      listener.endNamedFunctionExpression(token);
    } else {
      listener.endLocalFunctionDeclaration(token);
    }
    return token;
  }

  Token skipFunctionBody(Token token, bool isExpression) {
    assert(!isExpression);

    Token next = token.next!;

    String? value = next.toString();
    if (identical(value, ';')) {
      token = next;
      reportRecoverableError(token, codes.messageExpectedBody);

      listener.handleNoFunctionBody(token);
    } else if (identical(value, '=>')) {
      token = parseExpression(next);
      // There ought to be a semicolon following the expression, but we check
      // before advancing in order to be consistent with the way the method
      // [parseFunctionBody] recovers when the semicolon is missing.
      if (optional(';', token.next!)) {
        token = token.next!;
      }
      listener.handleFunctionBodySkipped(token, /* isExpressionBody = */ true);
    } else if (identical(value, '=')) {
      token = next;
      reportRecoverableError(token, codes.messageExpectedBody);
      token = parseExpression(token);
      // There ought to be a semicolon following the expression, but we check
      // before advancing in order to be consistent with the way the method
      // [parseFunctionBody] recovers when the semicolon is missing.
      if (optional(';', token.next!)) {
        token = token.next!;
      }
      listener.handleFunctionBodySkipped(token, /* isExpressionBody = */ true);
    } else {
      token = skipBlock(token);
      listener.handleFunctionBodySkipped(token, /* isExpressionBody = */ false);
    }
    return token;
  }

  /// Parses a function body.  This method is used in both expression context
  /// (when [ofFunctionExpression] is true) and statement context. In statement
  /// context (when [ofFunctionExpression] is false), and if the function body
  /// is on the form `=> expression`, a trailing semicolon is required.
  ///
  /// It's an error if there's no function body unless [allowAbstract] is true.
  Token parseFunctionBody(Token token, bool ofFunctionExpression) {
    Token next = token.next!;
    if (optional(';', next)) {
      reportRecoverableError(next, codes.messageExpectedBody);

      listener.handleEmptyFunctionBody(next);
      return next;
    } else if (optional('=>', next)) {
      return parseExpressionFunctionBody(next, ofFunctionExpression);
    } else if (optional('=', next)) {
      // Recover from a bad factory method.
      reportRecoverableError(next, codes.messageExpectedBody);
      next = rewriter.insertToken(
          next,
          SyntheticToken(
              type: TokenType.FUNCTION, offset: next.next!.charOffset));
      Token begin = next;
      token = parseExpression(next);
      if (!ofFunctionExpression) {
        token = ensureSemicolon(token);
        listener.handleExpressionFunctionBody(begin, token);
      } else {
        listener.handleExpressionFunctionBody(begin, /* endToken = */ null);
      }
      return token;
    }
    Token begin = next;
    int statementCount = 0;
    if (!optional('{', next)) {
      // Recovery
      // If `return` used instead of `=>`, then report an error and continue
      if (optional('return', next)) {
        reportRecoverableError(next, codes.messageExpectedBody);
        next = rewriter.insertToken(
            next,
            SyntheticToken(
                type: TokenType.FUNCTION, offset: next.next!.charOffset));
        return parseExpressionFunctionBody(next, ofFunctionExpression);
      }
      // If there is a stray simple identifier in the function expression
      // because the user is typing (e.g. `() asy => null;`)
      // then report an error, skip the token, and continue parsing.
      if (next.isKeywordOrIdentifier && optional('=>', next.next!)) {
        reportRecoverableErrorWithToken(next, codes.templateUnexpectedToken);
        return parseExpressionFunctionBody(next.next!, ofFunctionExpression);
      }
      if (next.isKeywordOrIdentifier && optional('{', next.next!)) {
        reportRecoverableErrorWithToken(next, codes.templateUnexpectedToken);
        token = next;
        begin = next = token.next!;
        // Fall through to parse the block.
      } else {
        // reportRecoverableError(next, codes.messageExpectedBody);

        // listener.handleEmptyFunctionBody(next);
        return next;
      }
      //  else {
      //   token = ensureBlock(token, codes.templateExpectedFunctionBody,
      //       /* missingBlockName = */ null);
      //   listener.handleInvalidFunctionBody(token);
      //   return token.endGroup!;
      // }
    }

    LoopState savedLoopState = loopState;
    loopState = LoopState.OutsideLoop;
    listener.beginBlockFunctionBody(begin);
    token = next;
    while (notEofOrValue('}', token.next!)) {
      Token startToken = token.next!;
      token = parseStatement(token);
      if (identical(token.next!, startToken)) {
        // No progress was made, so we report the current token as being invalid
        // and move forward.
        reportRecoverableError(
            token, codes.templateUnexpectedToken.withArguments(token));
        token = token.next!;
      }
      ++statementCount;
    }
    token = token.next!;
    assert(token.isEof || optional('}', token));
    listener.endBlockFunctionBody(statementCount, begin, token);
    loopState = savedLoopState;
    return token;
  }

  Token parseExpressionFunctionBody(Token token, bool ofFunctionExpression) {
    assert(optional('=>', token));
    Token begin = token;
    token = parseExpression(token);
    if (!ofFunctionExpression) {
      token = ensureSemicolon(token);
      listener.handleExpressionFunctionBody(begin, token);
    } else {
      listener.handleExpressionFunctionBody(begin, /* endToken = */ null);
    }

    return token;
  }

  int statementDepth = 0;
  Token parseStatement(Token token) {
    if (statementDepth++ > 500) {
      // This happens for degenerate programs, for example, a lot of nested
      // if-statements. The language test deep_nesting2_negative_test, for
      // example, provokes this.
      return recoverFromStackOverflow(token);
    }
    Token result = parseStatementX(token);
    statementDepth--;
    return result;
  }

  Token parseStatementX(Token token) {
    if (identical(token.next!.kind, IDENTIFIER_TOKEN)) {
      if (optional(':', token.next!.next!)) {
        return parseLabeledStatement(token);
      }
      return parseExpressionStatementOrDeclarationAfterModifiers(
          token,
          token,
          /* varFinalOrConst = */ null,
          /* typeInfo = */ null,
          /* onlyParseVariableDeclarationStart = */ false);
    }
    final String? value = token.next!.toString();
    if (identical(value, '{')) {
      // The scanner ensures that `{` always has a closing `}`.
      return parseBlock(token, BlockKind.statement);
    } else if (identical(value, 'return')) {
      return parseReturnStatement(token);
    } else if (identical(value, 'var')) {
      return parseExpressionStatementOrDeclaration(token);
    } else if (identical(value, 'if')) {
      return parseIfStatement(token);
    } else if (identical(value, 'for')) {
      return parseForStatement(token, /* awaitToken = */ null);
    } else if (identical(value, 'while')) {
      return parseWhileStatement(token);
    } else if (identical(value, 'do')) {
      return parseDoWhileStatement(token);
    } else if (identical(value, 'switch')) {
      return parseSwitchStatement(token);
    } else if (identical(value, 'break')) {
      return parseBreakStatement(token);
    } else if (identical(value, 'continue')) {
      return parseContinueStatement(token);
    } else if (identical(value, ';')) {
      return parseEmptyStatement(token);
    } else if (identical(value, 'set') && token.next!.next!.isIdentifier) {
      // Recovery: invalid use of `set`
      reportRecoverableErrorWithToken(
          token.next!, codes.templateUnexpectedToken);
      return parseStatementX(token.next!);
    } else if (token.next!.isIdentifier) {
      if (optional(':', token.next!.next!)) {
        return parseLabeledStatement(token);
      }
      return parseExpressionStatementOrDeclaration(token);
    } else {
      return parseExpressionStatementOrDeclaration(token);
    }
  }

  /// ```
  /// returnStatement:
  ///   'return' expression? ';'
  /// ;
  /// ```
  Token parseReturnStatement(Token token) {
    Token begin = token = token.next!;
    assert(optional('return', token));
    listener.beginReturnStatement(begin);
    Token next = token.next!;
    if (optional(';', next)) {
      listener.endReturnStatement(/* hasExpression = */ false, begin, next);
      return next;
    }
    token = parseExpression(token);
    token = ensureSemicolon(token);
    listener.endReturnStatement(/* hasExpression = */ true, begin, token);

    return token;
  }

  /// ```
  /// label:
  ///   identifier ':'
  /// ;
  /// ```
  Token parseLabel(Token token) {
    assert(token.next!.isIdentifier);
    token = ensureIdentifier(token, IdentifierContext.labelDeclaration).next!;
    assert(optional(':', token));
    listener.handleLabel(token);
    return token;
  }

  /// ```
  /// statement:
  ///   label* nonLabelledStatement
  /// ;
  /// ```
  Token parseLabeledStatement(Token token) {
    Token next = token.next!;
    assert(next.isIdentifier);
    assert(optional(':', next.next!));
    int labelCount = 0;
    do {
      token = parseLabel(token);
      next = token.next!;
      labelCount++;
    } while (next.isIdentifier && optional(':', next.next!));
    listener.beginLabeledStatement(next, labelCount);
    token = parseStatement(token);
    listener.endLabeledStatement(labelCount);
    return token;
  }

  /// ```
  /// expressionStatement:
  ///   expression? ';'
  /// ;
  /// ```
  ///
  /// Note: This method can fail to make progress. If there is neither an
  /// expression nor a semi-colon, then a synthetic identifier and synthetic
  /// semicolon will be inserted before [token] and the semicolon will be
  /// returned.
  Token parseExpressionStatement(Token token) {
    // TODO(brianwilkerson): If the next token is not the start of a valid
    // expression, then this method shouldn't report that we have an expression
    // statement.
    token = parseExpression(token);
    token = ensureSemicolon(token);
    listener.handleExpressionStatement(token);
    return token;
  }

  int expressionDepth = 0;
  Token parseExpression(Token token) {
    if (expressionDepth++ > 500) {
      // This happens in degenerate programs, for example, with a lot of nested
      // list literals. This is provoked by, for example, the language test
      // deep_nesting1_negative_test.
      Token next = token.next!;
      reportRecoverableError(next, codes.messageStackOverflow);

      // Recovery
      Token? endGroup = next.endGroup;
      if (endGroup != null) {
        while (!next.isEof && !identical(next, endGroup)) {
          token = next;
          next = token.next!;
        }
      } else {
        while (!isOneOf(next, const [')', ']', '}', ';'])) {
          token = next;
          next = token.next!;
        }
      }
      if (!token.isEof) {
        token = rewriter.insertSyntheticIdentifier(token);
        listener.handleIdentifier(token, IdentifierContext.expression);
      }
    } else {
      token = parsePrecedenceExpression(
          token, ASSIGNMENT_PRECEDENCE, /* allowCascades = */ true);
    }
    expressionDepth--;
    return token;
  }

  Token parseExpressionWithoutCascade(Token token) {
    return parsePrecedenceExpression(
        token, ASSIGNMENT_PRECEDENCE, /* allowCascades = */ false);
  }

  bool canParseAsConditional(Token question) {
    // We want to check if we can parse, not send events and permanently change
    // the token stream. Set it up so we can do that.
    Listener originalListener = listener;
    TokenStreamRewriter? originalRewriter = cachedRewriter;
    UndoableTokenStreamRewriter undoableTokenStreamRewriter =
        new UndoableTokenStreamRewriter();
    cachedRewriter = undoableTokenStreamRewriter;

    bool isConditional = false;

    Token afterExpression1 = parseExpressionWithoutCascade(question);
    if (optional(':', afterExpression1.next!)) {
      parseExpressionWithoutCascade(afterExpression1.next!);

      // Now we know it's a conditional expression.
      isConditional = true;
    }

    // Undo all changes and reset.
    undoableTokenStreamRewriter.undo();
    listener = originalListener;
    cachedRewriter = originalRewriter;

    return isConditional;
  }

  Token parseConditionalExpressionRest(Token token) {
    Token question = token = token.next!;
    assert(optional('?', question));
    listener.beginConditionalExpression(token);
    token = parseExpressionWithoutCascade(token);
    Token colon = ensureColon(token);
    listener.handleConditionalExpressionColon();
    token = parseExpressionWithoutCascade(colon);
    listener.endConditionalExpression(question, colon);
    return token;
  }

  Token parsePrecedenceExpression(
      Token token, int precedence, bool allowCascades) {
    assert(precedence >= 1);
    assert(precedence <= SELECTOR_PRECEDENCE);
    token = parseUnaryExpression(token, allowCascades);
    Token bangToken = token;
    if (optional('!', token.next!)) {
      bangToken = token.next!;
    }
    TypeParamOrArgInfo typeArg = computeMethodTypeArguments(bangToken);
    if (typeArg != noTypeParamOrArg) {
      // For example a(b)<T>(c), where token is before '<'.

      token = typeArg.parseArguments(bangToken, this);
      if (!optional('(', token.next!)) {
        listener.handleTypeArgumentApplication(bangToken.next!);
        typeArg = noTypeParamOrArg;
      }
    }

    return _parsePrecedenceExpressionLoop(
        precedence, allowCascades, typeArg, token);
  }

  Token _parsePrecedenceExpressionLoop(int precedence, bool allowCascades,
      TypeParamOrArgInfo typeArg, Token token) {
    Token next = token.next!;
    TokenType type = next.type;
    int tokenLevel = _computePrecedence(next);
    bool enteredLoop = false;
    for (int level = tokenLevel; level >= precedence; --level) {
      int lastBinaryExpressionLevel = -1;
      Token? lastCascade;
      while (identical(tokenLevel, level)) {
        enteredLoop = true;
        Token operator = next;
        if (identical(tokenLevel, ASSIGNMENT_PRECEDENCE)) {
          // Right associative, so we recurse at the same precedence
          // level.
          Token next = token.next!;
          if (optional(">=", next.next!)) {
            // Special case use of triple-shift in cases where it isn't
            // enabled.
            reportRecoverableErrorWithEnd(
                next,
                next.next!,
                codes.templateExperimentNotEnabled
                    .withArguments("triple-shift", "2.14"));
            assert(next == operator);
            next = rewriter.replaceNextTokensWithSyntheticToken(
                token, 2, TokenType.GT_GT_GT_EQ);
            operator = next;
          }
          token = parsePrecedenceExpression(next, level, allowCascades);
          listener.handleAssignmentExpression(operator);
        } else if (identical(tokenLevel, POSTFIX_PRECEDENCE)) {
          if ((identical(type, TokenType.PLUS_PLUS)) ||
              (identical(type, TokenType.MINUS_MINUS))) {
            listener.handleUnaryPostfixAssignmentExpression(token.next!);
            token = next;
          }
        } else if (identical(tokenLevel, SELECTOR_PRECEDENCE)) {
          if (identical(type, TokenType.PERIOD) ||
              identical(type, TokenType.QUESTION_PERIOD)) {
            // Left associative, so we recurse at the next higher precedence
            // level. However, SELECTOR_PRECEDENCE is the highest level, so we
            // should just call [parseUnaryExpression] directly. However, a
            // unary expression isn't legal after a period, so we call
            // [parsePrimary] instead.
            token = parsePrimary(
                token.next!, IdentifierContext.expressionContinuation);
            listener.handleEndingBinaryExpression(operator);

            Token bangToken = token;
            if (optional('!', token.next!)) {
              bangToken = token.next!;
            }
            typeArg = computeMethodTypeArguments(bangToken);
            if (typeArg != noTypeParamOrArg) {
              // For example e.f<T>(c), where token is before '<'.

              token = typeArg.parseArguments(bangToken, this);
              if (!optional('(', token.next!)) {
                listener.handleTypeArgumentApplication(bangToken.next!);
                typeArg = noTypeParamOrArg;
              }
            }
          } else if (identical(type, TokenType.OPEN_PAREN) ||
              identical(type, TokenType.OPEN_SQUARE_BRACKET)) {
            token = parseArgumentOrIndexStar(
                token, typeArg, /* checkedNullAware = */ false);
          } else if (identical(type, TokenType.QUESTION)) {
            // We have determined selector precedence so this is a null-aware
            // bracket operator.
            token = parseArgumentOrIndexStar(
                token, typeArg, /* checkedNullAware = */ true);
          } else if (identical(type, TokenType.INDEX)) {
            rewriteSquareBrackets(token);
            token = parseArgumentOrIndexStar(
                token, noTypeParamOrArg, /* checkedNullAware = */ false);
          } else {
            // Recovery
            reportRecoverableErrorWithToken(
                token.next!, codes.templateUnexpectedToken);
            token = next;
          }
        } else if (identical(type, TokenType.QUESTION)) {
          token = parseConditionalExpressionRest(token);
        } else {
          if (level == EQUALITY_PRECEDENCE || level == RELATIONAL_PRECEDENCE) {
            // We don't allow (a == b == c) or (a < b < c).
            if (lastBinaryExpressionLevel == level) {
              // Report an error, then continue parsing as if it is legal.
              reportRecoverableError(
                  next, codes.messageEqualityCannotBeEqualityOperand);
            } else {
              // Set a flag to catch subsequent binary expressions of this type.
              lastBinaryExpressionLevel = level;
            }
          }
          if (optional(">>", next) && next.charEnd == next.next!.charOffset) {
            if (optional(">", next.next!)) {
              // Special case use of triple-shift in cases where it isn't
              // enabled.
              reportRecoverableErrorWithEnd(
                  next,
                  next.next!,
                  codes.templateExperimentNotEnabled
                      .withArguments("triple-shift", "2.14"));
              assert(next == operator);
              next = rewriter.replaceNextTokensWithSyntheticToken(
                  token, 2, TokenType.GT_GT_GT);
              operator = next;
            }
          }
          listener.beginBinaryExpression(next);
          // Left associative, so we recurse at the next higher
          // precedence level.
          token =
              parsePrecedenceExpression(token.next!, level + 1, allowCascades);
          listener.endBinaryExpression(operator);
        }
        next = token.next!;
        type = next.type;
        tokenLevel = _computePrecedence(next);
      }
      if (_recoverAtPrecedenceLevel && !_currentlyRecovering) {
        // Attempt recovery
        if (_attemptPrecedenceLevelRecovery(
            token, precedence, level, allowCascades, typeArg)) {
          // Recovered - try again at same level with the replacement token.
          level++;
          next = token.next!;
          type = next.type;
          tokenLevel = _computePrecedence(next);
        }
      }
    }

    if (!enteredLoop && _recoverAtPrecedenceLevel && !_currentlyRecovering) {
      // Attempt recovery
      if (_attemptPrecedenceLevelRecovery(
          token, precedence, /*currentLevel = */ -1, allowCascades, typeArg)) {
        return _parsePrecedenceExpressionLoop(
            precedence, allowCascades, typeArg, token);
      }
    }
    return token;
  }

  /// Attempt a recovery where [token.next] is replaced.
  bool _attemptPrecedenceLevelRecovery(Token token, int precedence,
      int currentLevel, bool allowCascades, TypeParamOrArgInfo typeArg) {
    // Attempt recovery.
    _recoverAtPrecedenceLevel = false;
    assert(_tokenRecoveryReplacements.containsKey(token.next!.lexeme));
    List<TokenType> replacements =
        _tokenRecoveryReplacements[token.next!.lexeme]!;
    for (int i = 0; i < replacements.length; i++) {
      TokenType replacement = replacements[i];

      if (currentLevel >= 0) {
        // Check that the new precedence and currentLevel would have accepted
        // this replacement here.
        int newLevel = replacement.precedence;
        // The loop it would normally have gone through is something like
        // for (; ; --level) {
        //   while (identical(tokenLevel, level)) {
        //   }
        // }
        // So if the new tokens level <= the "old" (current) level, [level] (in
        // the above code snippet) would get down to it and accept it.
        // But if the new tokens level > the "old" (current) level, normally we
        // would never get to it - so we shouldn't here either.
        // As the loop starts by taking the first tokens tokenLevel as level,
        // recursing below won't weed that out so we need to do it here.
        if (newLevel > currentLevel) continue;
      }

      _currentlyRecovering = true;
      Listener originalListener = listener;
      TokenStreamRewriter? originalRewriter = cachedRewriter;
      UndoableTokenStreamRewriter undoableTokenStreamRewriter =
          new UndoableTokenStreamRewriter();
      cachedRewriter = undoableTokenStreamRewriter;
      rewriter.replaceNextTokenWithSyntheticToken(token, replacement);
      bool acceptRecovery = false;
      Token afterExpression = _parsePrecedenceExpressionLoop(
          precedence, allowCascades, typeArg, token);
      Token afterExpressionNext = afterExpression.next!;

      if (token != afterExpression &&
          (isOneOfOrEof(afterExpressionNext,
                  const [';', ',', ')', '{', '}', '|', '||', '&', '&&']) ||
              (afterExpressionNext.type == TokenType.IDENTIFIER &&
                  _tokenRecoveryReplacements
                      .containsKey(afterExpressionNext.lexeme)))) {
        // Seems good!
        acceptRecovery = true;
      }

      // Undo all changes and reset.
      _currentlyRecovering = false;
      undoableTokenStreamRewriter.undo();
      listener = originalListener;
      cachedRewriter = originalRewriter;

      if (acceptRecovery) {
        // Report and redo recovery.
        reportRecoverableError(
            token.next!,
            codes.templateBinaryOperatorWrittenOut
                .withArguments(token.next!.lexeme, replacement.lexeme));
        rewriter.replaceNextTokenWithSyntheticToken(token, replacement);
        return true;
      }
    }

    return false;
  }

  bool _recoverAtPrecedenceLevel = false;
  bool _currentlyRecovering = false;
  static const Map<String, List<TokenType>> _tokenRecoveryReplacements = const {
    // E.g. in Kotlin binary operators are written out, see.
    // https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-int/.
    "xor": [
      TokenType.CARET,
    ],
    "and": [
      TokenType.AMPERSAND,
      TokenType.AMPERSAND_AMPERSAND,
    ],
    "or": [
      TokenType.BAR,
      TokenType.BAR_BAR,
    ],
    "shl": [
      TokenType.LT_LT,
    ],
    "shr": [
      TokenType.GT_GT,
    ],
  };

  int _computePrecedence(Token token) {
    TokenType type = token.type;
    if (identical(type, TokenType.BANG)) {
      // The '!' has prefix precedence but here it's being used as a
      // postfix operator to assert the expression has a non-null value.
      TokenType nextType = token.next!.type;
      if (identical(nextType, TokenType.PERIOD) ||
          identical(nextType, TokenType.QUESTION) ||
          identical(nextType, TokenType.OPEN_PAREN) ||
          identical(nextType, TokenType.OPEN_SQUARE_BRACKET) ||
          identical(nextType, TokenType.QUESTION_PERIOD)) {
        return SELECTOR_PRECEDENCE;
      }
      return POSTFIX_PRECEDENCE;
    } else if (identical(type, TokenType.GT_GT)) {
      // ">>" followed by ">=" (without space between tokens) should for
      // recovery be seen as ">>>=".
      TokenType nextType = token.next!.type;
      if (identical(nextType, TokenType.GT_EQ) &&
          token.charEnd == token.next!.offset) {
        return TokenType.GT_GT_GT_EQ.precedence;
      }
    } else if (identical(type, TokenType.QUESTION) &&
        optional('[', token.next!)) {
      // "?[" can be a null-aware bracket or a conditional. If it's a
      // null-aware bracket it has selector precedence.
      bool isConditional = canParseAsConditional(token);
      if (!isConditional) {
        return SELECTOR_PRECEDENCE;
      }
    } else if (identical(type, TokenType.IDENTIFIER)) {
      // An identifier at this point is not right. So some recovery is going to
      // happen soon. The question is, if we can do a better recovery here.
      if (!_currentlyRecovering &&
          _tokenRecoveryReplacements.containsKey(token.lexeme)) {
        _recoverAtPrecedenceLevel = true;
      }
    }

    return type.precedence;
  }

  Token parseUnaryExpression(Token token, bool allowCascades) {
    String? value = token.next!.toString();
    // Prefix:
    if (identical(value, '+')) {
      // Dart no longer allows prefix-plus.
      rewriteAndRecover(
          token,
          // TODO(danrubel): Consider reporting "missing identifier" instead.
          codes.messageUnsupportedPrefixPlus,
          SyntheticStringToken(
              type: TokenType.IDENTIFIER,
              value: '',
              offset: token.next!.offset));
      return parsePrimary(token, IdentifierContext.expression);
    } else if ((identical(value, '!')) ||
        (identical(value, '-')) ||
        (identical(value, '~'))) {
      Token operator = token.next!;
      // Right associative, so we recurse at the same precedence
      // level.
      token = parsePrecedenceExpression(
          token.next!, POSTFIX_PRECEDENCE, allowCascades);
      listener.handleUnaryPrefixExpression(operator);
      return token;
    } else if ((identical(value, '++')) || identical(value, '--')) {
      // TODO(ahe): Validate this is used correctly.
      Token operator = token.next!;
      // Right associative, so we recurse at the same precedence
      // level.
      token = parsePrecedenceExpression(
          token.next!, POSTFIX_PRECEDENCE, allowCascades);
      listener.handleUnaryPrefixAssignmentExpression(operator);
      return token;
    } else if (useImplicitCreationExpression && token.next!.isIdentifier) {
      // Token identifier = token.next!;
      // if (optional(".", identifier.next!)) {
      //   identifier = identifier.next!.next!;
      // }
      // if (identifier.isIdentifier) {
      //   // Looking at `identifier ('.' identifier)?`.
      //   if (optional("<", identifier.next!)) {
      //     TypeParamOrArgInfo typeArg = computeTypeParamOrArg(identifier);
      //     if (typeArg != noTypeParamOrArg) {
      //       Token endTypeArguments = typeArg.skip(identifier);
      //       Token afterTypeArguments = endTypeArguments.next!;
      //       if (optional(".", afterTypeArguments)) {
      //         Token afterPeriod = afterTypeArguments.next!;
      //         if (_isNewOrIdentifier(afterPeriod) &&
      //             optional('(', afterPeriod.next!)) {
      //           return parseImplicitCreationExpression(
      //               token, identifier.next!, typeArg);
      //         }
      //       }
      //     }
      //   }
      // }
    }
    return parsePrimary(token, IdentifierContext.expression);
  }

  Token parseArgumentOrIndexStar(
      Token token, TypeParamOrArgInfo typeArg, bool checkedNullAware) {
    Token next = token.next!;
    final Token beginToken = next;
    while (true) {
      bool potentialNullAware =
          (optional('?', next) && optional('[', next.next!));
      if (potentialNullAware && !checkedNullAware) {
        // While it's a potential null aware index it hasn't been checked.
        // It might be a conditional expression.
        assert(optional('?', next));
        bool isConditional = canParseAsConditional(next);
        if (isConditional) potentialNullAware = false;
      }

      if (optional('[', next) || potentialNullAware) {
        assert(typeArg == noTypeParamOrArg);
        Token openSquareBracket = next;
        Token? question;
        if (optional('?', next)) {
          question = next;
          next = next.next!;
          openSquareBracket = next;
          assert(optional('[', openSquareBracket));
        }
        bool old = mayParseFunctionExpressions;
        mayParseFunctionExpressions = true;
        token = parseExpression(next);
        next = token.next!;
        mayParseFunctionExpressions = old;
        if (!optional(']', next)) {
          // Recovery
          reportRecoverableError(
              next, codes.templateExpectedButGot.withArguments(']'));
          // Scanner ensures a closing ']'
          Token endGroup = openSquareBracket.endGroup!;
          if (endGroup.isSynthetic) {
            // Scanner inserted closing ']' in the wrong place, so move it.
            next = rewriter.moveSynthetic(token, endGroup);
          } else {
            // Skip over unexpected tokens to where the user placed the `]`.
            next = endGroup;
          }
        }
        listener.handleIndexedExpression(question, openSquareBracket, next);
        token = next;
        Token bangToken = token;
        if (optional('!', token.next!)) {
          bangToken = token.next!;
        }
        typeArg = computeMethodTypeArguments(bangToken);
        if (typeArg != noTypeParamOrArg) {
          // For example a[b]<T>(c), where token is before '<'.
          token = typeArg.parseArguments(bangToken, this);
          if (!optional('(', token.next!)) {
            listener.handleTypeArgumentApplication(bangToken.next!);
            typeArg = noTypeParamOrArg;
          }
        }
        next = token.next!;
      } else if (optional('(', next)) {
        if (typeArg == noTypeParamOrArg) {
          listener.handleNoTypeArguments(next);
        }
        token = parseArguments(token);
        listener.handleSend(beginToken, token);
        Token bangToken = token;
        if (optional('!', token.next!)) {
          bangToken = token.next!;
        }
        typeArg = computeMethodTypeArguments(bangToken);
        if (typeArg != noTypeParamOrArg) {
          // For example a(b)<T>(c), where token is before '<'.
          token = typeArg.parseArguments(bangToken, this);
          if (!optional('(', token.next!)) {
            listener.handleTypeArgumentApplication(bangToken.next!);
            typeArg = noTypeParamOrArg;
          }
        }
        next = token.next!;
      } else {
        break;
      }
    }
    return token;
  }

  Token parsePrimary(Token token, IdentifierContext context) {
    final int kind = token.next!.kind;
    if (kind == IDENTIFIER_TOKEN) {
      return parseSendOrFunctionLiteral(token, context);
    } else if (kind == INT_TOKEN || kind == HEXADECIMAL_TOKEN) {
      return parseLiteralInt(token);
    } else if (kind == DOUBLE_TOKEN) {
      return parseLiteralDouble(token);
    } else if (kind == STRING_TOKEN) {
      return parseLiteralString(token);
    } else if (kind == HASH_TOKEN) {
      return parseLiteralSymbol(token);
    } else if (kind == KEYWORD_TOKEN) {
      final String? value = token.next!.toString();
      if (identical(value, "true") || identical(value, "false")) {
        return parseLiteralBool(token);
      } else if (identical(value, "null")) {
        return parseLiteralNull(token);
      } else if (identical(value, "void")) {
        return parseSendOrFunctionLiteral(token, context);
      } else if (token.next!.isIdentifier) {
        return parseSendOrFunctionLiteral(token, context);
      } else if (identical(value, "return")) {
        // Recovery
        token = token.next!;
        reportRecoverableErrorWithToken(token, codes.templateUnexpectedToken);
        return parsePrimary(token, context);
      } else {
        // Fall through to the recovery code.
      }
    } else if (kind == OPEN_PAREN_TOKEN) {
      return parseParenthesizedExpressionOrFunctionLiteral(token);
    } else if (kind == OPEN_SQUARE_BRACKET_TOKEN ||
        optional('[]', token.next!)) {
      listener.handleNoTypeArguments(token.next!);
      return parseLiteralListSuffix(token, /* constKeyword = */ null);
    } else if (kind == OPEN_CURLY_BRACKET_TOKEN) {
      listener.handleNoTypeArguments(token.next!);
      return parseLiteralSetOrMapSuffix(token, /* constKeyword = */ null);
    } else if (kind == LT_TOKEN) {
      return parseLiteralListSetMapOrFunction(token, /* constKeyword = */ null);
    } else {
      // Fall through to the recovery code.
    }
    //
    // Recovery code.
    //
    return parseSend(token, context);
  }

  Token parseParenthesizedExpressionOrFunctionLiteral(Token token) {
    Token next = token.next!;
    assert(optional('(', next));
    Token nextToken = next.endGroup!.next!;
    int kind = nextToken.kind;
    if (mayParseFunctionExpressions) {
      if ((identical(kind, FUNCTION_TOKEN) ||
          identical(kind, OPEN_CURLY_BRACKET_TOKEN))) {
        listener.handleNoTypeVariables(next);
        return parseFunctionExpression(token);
      }
    }
    bool old = mayParseFunctionExpressions;
    mayParseFunctionExpressions = true;
    token = parseParenthesizedExpression(token);
    mayParseFunctionExpressions = old;
    return token;
  }

  Token ensureParenthesizedCondition(Token token) {
    Token openParen = token.next!;
    if (!optional('(', openParen)) {
      // Recover
      reportRecoverableError(
          openParen, codes.templateExpectedToken.withArguments('('));
      openParen = rewriter.insertParens(token, /* includeIdentifier = */ false);
    }
    token = parseExpressionInParenthesisRest(openParen);
    listener.handleParenthesizedCondition(openParen);
    return token;
  }

  Token parseParenthesizedExpression(Token token) {
    Token begin = token.next!;
    token = parseExpressionInParenthesis(token);
    listener.handleParenthesizedExpression(begin);
    return token;
  }

  Token parseExpressionInParenthesis(Token token) {
    return parseExpressionInParenthesisRest(token.next!);
  }

  Token parseExpressionInParenthesisRest(Token token) {
    assert(optional('(', token));
    BeginToken begin = token as BeginToken;
    token = parseExpression(token);
    token = ensureCloseParen(token, begin);
    assert(optional(')', token));
    return token;
  }

  /// This method parses the portion of a list literal starting with the left
  /// square bracket.
  ///
  /// ```
  /// listLiteral:
  ///   'const'? typeArguments? '[' (expressionList ','?)? ']'
  /// ;
  /// ```
  ///
  /// Provide a [constKeyword] if the literal is preceded by 'const', or `null`
  /// if not. This is a suffix parser because it is assumed that type arguments
  /// have been parsed, or `listener.handleNoTypeArguments` has been executed.
  Token parseLiteralListSuffix(Token token, Token? constKeyword) {
    Token beforeToken = token;
    Token beginToken = token = token.next!;
    assert(optional('[', token) || optional('[]', token));
    int count = 0;
    if (optional('[]', token)) {
      token = rewriteSquareBrackets(beforeToken).next!;
      listener.handleLiteralList(
        /* count = */ 0,
        token,
        constKeyword,
        token.next!,
      );
      return token.next!;
    }
    bool old = mayParseFunctionExpressions;
    mayParseFunctionExpressions = true;
    while (true) {
      Token next = token.next!;
      if (optional(']', next)) {
        token = next;
        break;
      }
      int ifCount = 0;
      LiteralEntryInfo? info = computeLiteralEntry(token);
      while (info != null) {
        if (info.hasEntry) {
          token = parseExpression(token);
        } else {
          token = info.parse(token, this);
        }
        ifCount += info.ifConditionDelta;
        info = info.computeNext(token);
      }
      next = token.next!;
      ++count;
      if (!optional(',', next)) {
        if (optional(']', next)) {
          token = next;
          break;
        }

        // Recovery
        if (!looksLikeLiteralEntry(next)) {
          if (beginToken.endGroup!.isSynthetic) {
            // The scanner has already reported an error,
            // but inserted `]` in the wrong place.
            token = rewriter.moveSynthetic(token, beginToken.endGroup!);
          } else {
            // Report an error and jump to the end of the list.
            reportRecoverableError(
                next, codes.templateExpectedButGot.withArguments(']'));
            token = beginToken.endGroup!;
          }
          break;
        }
        // This looks like the start of an expression.
        // Report an error, insert the comma, and continue parsing.
        SyntheticToken comma =
            SyntheticToken(type: TokenType.COMMA, offset: next.offset);
        codes.Message message = ifCount > 0
            ? codes.messageExpectedElseOrComma
            : codes.templateExpectedButGot.withArguments(',');
        next = rewriteAndRecover(token, message, comma);
      }
      token = next;
    }
    mayParseFunctionExpressions = old;
    listener.handleLiteralList(count, beginToken, constKeyword, token);
    return token;
  }

  /// This method parses the portion of a set or map literal that starts with
  /// the left curly brace when there are no leading type arguments.
  Token parseLiteralSetOrMapSuffix(Token token, Token? constKeyword) {
    Token leftBrace = token = token.next!;
    assert(optional('{', leftBrace));
    Token next = token.next!;
    if (optional('}', next)) {
      listener.handleLiteralSetOrMap(/* count = */ 0, leftBrace, constKeyword,
          next, /* hasSetEntry = */ false);
      return next;
    }

    final bool old = mayParseFunctionExpressions;
    mayParseFunctionExpressions = true;
    int count = 0;
    // TODO(danrubel): hasSetEntry parameter exists for replicating existing
    // behavior and will be removed once unified collection has been enabled
    bool? hasSetEntry;

    while (true) {
      int ifCount = 0;
      LiteralEntryInfo? info = computeLiteralEntry(token);
      if (info == simpleEntry) {
        // TODO(danrubel): Remove this section and use the while loop below
        // once hasSetEntry is no longer needed.
        token = parseExpression(token);
        bool isMapEntry = optional(':', token.next!);
        hasSetEntry ??= !isMapEntry;
        if (isMapEntry) {
          Token colon = token.next!;
          token = parseExpression(colon);
          listener.handleLiteralMapEntry(colon, token.next!);
        }
      } else {
        while (info != null) {
          if (info.hasEntry) {
            token = parseExpression(token);
            if (optional(':', token.next!)) {
              Token colon = token.next!;
              token = parseExpression(colon);
              listener.handleLiteralMapEntry(colon, token.next!);
            }
          } else {
            token = info.parse(token, this);
          }
          ifCount += info.ifConditionDelta;
          info = info.computeNext(token);
        }
      }
      ++count;
      next = token.next!;

      Token? comma;
      if (optional(',', next)) {
        comma = token = next;
        next = token.next!;
      }
      if (optional('}', next)) {
        listener.handleLiteralSetOrMap(
            count, leftBrace, constKeyword, next, hasSetEntry ?? false);
        mayParseFunctionExpressions = old;
        return next;
      }

      if (comma == null) {
        // Recovery
        if (looksLikeLiteralEntry(next)) {
          // If this looks like the start of an expression,
          // then report an error, insert the comma, and continue parsing.
          // TODO(danrubel): Consider better error message
          SyntheticToken comma =
              SyntheticToken(type: TokenType.COMMA, offset: next.offset);
          codes.Message message = ifCount > 0
              ? codes.messageExpectedElseOrComma
              : codes.templateExpectedButGot.withArguments(',');
          token = rewriteAndRecover(token, message, comma);
        } else {
          reportRecoverableError(
              next, codes.templateExpectedButGot.withArguments('}'));
          // Scanner guarantees a closing curly bracket
          next = leftBrace.endGroup!;
          listener.handleLiteralSetOrMap(
              count, leftBrace, constKeyword, next, hasSetEntry ?? false);
          mayParseFunctionExpressions = old;
          return next;
        }
      }
    }
  }

  /// formalParameterList functionBody.
  ///
  /// This is a suffix parser because it is assumed that type arguments have
  /// been parsed, or `listener.handleNoTypeArguments(..)` has been executed.
  Token parseLiteralFunctionSuffix(Token token) {
    assert(optional('(', token.next!));
    // Scanner ensures `(` has matching `)`.
    Token next = token.next!.endGroup!.next!;
    int kind = next.kind;
    if (!identical(kind, FUNCTION_TOKEN) &&
        !identical(kind, OPEN_CURLY_BRACKET_TOKEN) &&
        (!identical(kind, KEYWORD_TOKEN) ||
            !optional('async', next) && !optional('sync', next))) {
      reportRecoverableErrorWithToken(next, codes.templateUnexpectedToken);
    }
    return parseFunctionExpression(token);
  }

  /// genericListLiteral | genericMapLiteral | genericFunctionLiteral.
  ///
  /// Where
  ///   genericListLiteral ::= typeArguments '[' (expressionList ','?)? ']'
  ///   genericMapLiteral ::=
  ///       typeArguments '{' (mapLiteralEntry (',' mapLiteralEntry)* ','?)? '}'
  ///   genericFunctionLiteral ::=
  ///       typeParameters formalParameterList functionBody
  /// Provide token for [constKeyword] if preceded by 'const', null if not.
  Token parseLiteralListSetMapOrFunction(
      final Token start, Token? constKeyword) {
    assert(optional('<', start.next!));
    TypeParamOrArgInfo typeParamOrArg =
        computeTypeParamOrArg(start, /* inDeclaration = */ true);
    Token token = typeParamOrArg.skip(start);
    if (optional('(', token.next!)) {
      if (constKeyword != null) {
        reportRecoverableErrorWithToken(
            constKeyword, codes.templateUnexpectedToken);
      }
      token = typeParamOrArg.parseVariables(start, this);
      return parseLiteralFunctionSuffix(token);
    }
    // Note that parseArguments can rewrite the token stream!
    token = typeParamOrArg.parseArguments(start, this);
    Token next = token.next!;
    if (optional('{', next)) {
      if (typeParamOrArg.typeArgumentCount > 2) {
        reportRecoverableErrorWithEnd(start.next!, token,
            codes.messageSetOrMapLiteralTooManyTypeArguments);
      }
      return parseLiteralSetOrMapSuffix(token, constKeyword);
    }
    if (!optional('[', next) && !optional('[]', next)) {
      // TODO(danrubel): Improve this error message.
      reportRecoverableError(
          next, codes.templateExpectedButGot.withArguments('['));
      rewriter.insertSyntheticToken(token, TokenType.INDEX);
    }
    return parseLiteralListSuffix(token, constKeyword);
  }

  /// ```
  /// mapLiteralEntry:
  ///   expression ':' expression |
  ///   'if' '(' expression ')' mapLiteralEntry ( 'else' mapLiteralEntry )? |
  ///   'await'? 'for' '(' forLoopParts ')' mapLiteralEntry |
  ///   ( '...' | '...?' ) expression
  /// ;
  /// ```
  Token parseMapLiteralEntry(Token token) {
    // Assume the listener rejects non-string keys.
    // TODO(brianwilkerson): Change the assumption above by moving error
    // checking into the parser, making it possible to recover.
    LiteralEntryInfo? info = computeLiteralEntry(token);
    while (info != null) {
      if (info.hasEntry) {
        token = parseExpression(token);
        Token colon = ensureColon(token);
        token = parseExpression(colon);
        // TODO remove unused 2nd parameter
        listener.handleLiteralMapEntry(colon, token.next!);
      } else {
        token = info.parse(token, this);
      }
      info = info.computeNext(token);
    }
    return token;
  }

  Token parseSendOrFunctionLiteral(Token token, IdentifierContext context) {
    if (!mayParseFunctionExpressions) {
      return parseSend(token, context);
    }
    TypeInfo typeInfo = computeType(token, /* required = */ false);
    Token beforeName = typeInfo.skipType(token);
    Token name = beforeName.next!;
    if (name.isIdentifier) {
      TypeParamOrArgInfo typeParam = computeTypeParamOrArg(name);
      Token next = typeParam.skip(name).next!;
      if (optional('(', next)) {
        if (looksLikeFunctionBody(next.endGroup!.next!)) {
          return parseFunctionLiteral(
              token, beforeName, name, typeInfo, typeParam, context);
        }
      }
    }
    return parseSend(token, context);
  }

  Token ensureArguments(Token token) {
    Token next = token.next!;
    if (!optional('(', next)) {
      reportRecoverableError(
          token, codes.templateExpectedAfterButGot.withArguments('('));
      next = rewriter.insertParens(token, /* includeIdentifier = */ false);
    }
    return parseArgumentsRest(next);
  }

  Token parseConstructorInvocationArguments(Token token) {
    Token next = token.next!;
    if (!optional('(', next)) {
      // Recovery: Check for invalid type parameters
      TypeParamOrArgInfo typeArg = computeTypeParamOrArg(token);
      if (typeArg == noTypeParamOrArg) {
        reportRecoverableError(
            token, codes.templateExpectedAfterButGot.withArguments('('));
      } else {
        reportRecoverableError(
            token, codes.messageConstructorWithTypeArguments);
        token = typeArg.parseArguments(token, this);
        listener.handleInvalidTypeArguments(token);
        next = token.next!;
      }
      if (!optional('(', next)) {
        next = rewriter.insertParens(token, /* includeIdentifier = */ false);
      }
    }
    return parseArgumentsRest(next);
  }

  /// ```
  /// intLiteral:
  ///   integer
  /// ;
  /// ```
  Token parseLiteralInt(Token token) {
    token = token.next!;
    assert(identical(token.kind, INT_TOKEN) ||
        identical(token.kind, HEXADECIMAL_TOKEN));
    listener.handleLiteralInt(token);
    return token;
  }

  /// ```
  /// doubleLiteral:
  ///   double
  /// ;
  /// ```
  Token parseLiteralDouble(Token token) {
    token = token.next!;
    assert(identical(token.kind, DOUBLE_TOKEN));
    listener.handleLiteralDouble(token);
    return token;
  }

  /// ```
  /// stringLiteral:
  ///   (multilineString | singleLineString)+
  /// ;
  /// ```
  Token parseLiteralString(Token token) {
    Token startToken = token;
    assert(identical(token.next!.kind, STRING_TOKEN));
    bool old = mayParseFunctionExpressions;
    mayParseFunctionExpressions = true;
    token = parseSingleLiteralString(token);
    int count = 1;
    while (identical(token.next!.kind, STRING_TOKEN)) {
      token = parseSingleLiteralString(token);
      count++;
    }
    if (count > 1) {
      listener.handleStringJuxtaposition(startToken, count);
    }
    mayParseFunctionExpressions = old;
    return token;
  }

  /// ```
  /// symbolLiteral:
  ///   '#' (operator | (identifier ('.' identifier)*))
  /// ;
  /// ```
  Token parseLiteralSymbol(Token token) {
    Token hashToken = token = token.next!;
    assert(optional('#', hashToken));
    listener.beginLiteralSymbol(hashToken);
    Token next = token.next!;
    if (optional('void', next)) {
      listener.handleSymbolVoid(next);
      listener.endLiteralSymbol(hashToken, /* identifierCount = */ 1);
      return next;
    } else {
      int count = 1;
      token = ensureIdentifier(token, IdentifierContext.literalSymbol);
      while (optional('.', token.next!)) {
        count++;
        token = ensureIdentifier(
            token.next!, IdentifierContext.literalSymbolContinuation);
      }
      listener.endLiteralSymbol(hashToken, count);
      return token;
    }
  }

  Token parseSingleLiteralString(Token token) {
    token = token.next!;
    assert(identical(token.kind, STRING_TOKEN));
    listener.beginLiteralString(token);
    // Parsing the prefix, for instance 'x of 'x${id}y${id}z'
    int interpolationCount = 0;
    Token next = token.next!;
    int kind = next.kind;
    while (kind != EOF_TOKEN) {
      if (identical(kind, STRING_INTERPOLATION_TOKEN)) {
        // Parsing ${expression}.
        token = parseExpression(next).next!;
        if (!optional('}', token)) {
          reportRecoverableError(
              token, codes.templateExpectedButGot.withArguments('}'));
          token = next.endGroup!;
        }
        listener.handleInterpolationExpression(next, token);
      } else if (identical(kind, STRING_INTERPOLATION_IDENTIFIER_TOKEN)) {
        // Parsing $identifier.
        token = parseIdentifierExpression(next);
        listener.handleInterpolationExpression(next, /* rightBracket = */ null);
      } else {
        break;
      }
      ++interpolationCount;
      // Parsing the infix/suffix, for instance y and z' of 'x${id}y${id}z'
      token = parseStringPart(token);
      next = token.next!;
      kind = next.kind;
    }
    listener.endLiteralString(interpolationCount, next);
    return token;
  }

  Token parseIdentifierExpression(Token token) {
    return parseSend(token, IdentifierContext.expression);
  }

  /// ```
  /// booleanLiteral:
  ///   'true' |
  ///   'false'
  /// ;
  /// ```
  Token parseLiteralBool(Token token) {
    token = token.next!;
    assert(optional('false', token) || optional('true', token));
    listener.handleLiteralBool(token);
    return token;
  }

  /// ```
  /// nullLiteral:
  ///   'null'
  /// ;
  /// ```
  Token parseLiteralNull(Token token) {
    token = token.next!;
    assert(optional('null', token));
    listener.handleLiteralNull(token);
    return token;
  }

  Token parseSend(Token token, IdentifierContext context) {
    // Least-costly recovery of `Map<...>?{`, `Set<...>?{`, `List<...>[` and
    // `List<...>?[]`.
    // Note that we have to "peek" into the identifier because we don't want to
    // send an `handleIdentifier` if we end up recovering.
    TypeParamOrArgInfo? potentialTypeArg;
    Token? afterToken;
    if (isNextIdentifier(token)) {
      Token identifier = token.next!;
      String value = identifier.lexeme;
      if (value == "Map" || value == "Set") {
        potentialTypeArg = computeTypeParamOrArg(identifier);
        afterToken = potentialTypeArg.skip(identifier).next!;
        if (optional('{', afterToken)) {
          // Recover by ignoring the `Map`/`Set` and parse as a literal map/set.
          reportRecoverableError(
              identifier,
              codes.templateLiteralWithClass
                  .withArguments(value.toLowerCase(), identifier));
          return parsePrimary(identifier, context);
        }
      } else if (value == "List") {
        potentialTypeArg = computeTypeParamOrArg(identifier);
        afterToken = potentialTypeArg.skip(identifier).next!;
        if ((potentialTypeArg != noTypeParamOrArg &&
                optional('[', afterToken)) ||
            optional('[]', afterToken)) {
          // Recover by ignoring the `List` and parse as a literal List.
          // Note that we here require the `<...>` for `[` as `List[` would be
          // an indexed expression. `List[]` wouldn't though, so we don't
          // require it there.
          reportRecoverableError(
              identifier,
              codes.templateLiteralWithClass
                  .withArguments(value.toLowerCase(), identifier));
          return parsePrimary(identifier, context);
        }
      }
    }

    Token beginToken = token = ensureIdentifier(token, context);
    // Notice that we don't parse the bang (!) here as we do in many other
    // instances where we call computeMethodTypeArguments.
    // The reason is, that on a method call like "e.f!<int>()" we need the
    // "e.f" to become a "single unit" before processing the bang (!),
    // the type arguments and the arguments.
    // By not handling bang here we don't parse any of it, and the parser will
    // parse it correctly in a different recursion step.

    // Special-case [computeMethodTypeArguments] to re-use potentialTypeArg if
    // already computed.
    potentialTypeArg ??= computeTypeParamOrArg(token);
    afterToken ??= potentialTypeArg.skip(token).next!;
    TypeParamOrArgInfo typeArg;
    if (optional('(', afterToken) && !potentialTypeArg.recovered) {
      typeArg = potentialTypeArg;
    } else {
      typeArg = noTypeParamOrArg;
    }

    if (typeArg != noTypeParamOrArg) {
      token = typeArg.parseArguments(token, this);
    } else {
      listener.handleNoTypeArguments(token.next!);
    }
    token = parseArgumentsOpt(token);
    listener.handleSend(beginToken, token.next!);
    return token;
  }

  Token skipArgumentsOpt(Token token) {
    Token next = token.next!;
    listener.handleNoArguments(next);
    if (optional('(', next)) {
      return next.endGroup!;
    } else {
      return token;
    }
  }

  Token parseArgumentsOpt(Token token) {
    Token next = token.next!;
    if (!optional('(', next)) {
      listener.handleNoArguments(next);
      return token;
    } else {
      return parseArguments(token);
    }
  }

  /// ```
  /// arguments:
  ///   '(' (argumentList ','?)? ')'
  /// ;
  ///
  /// argumentList:
  ///   namedArgument (',' namedArgument)* |
  ///   expressionList (',' namedArgument)*
  /// ;
  ///
  /// namedArgument:
  ///   label expression
  /// ;
  /// ```
  Token parseArguments(Token token) {
    return parseArgumentsRest(token.next!);
  }

  Token parseArgumentsRest(Token token) {
    Token begin = token;
    assert(optional('(', begin));
    listener.beginArguments(begin);
    int argumentCount = 0;
    bool old = mayParseFunctionExpressions;
    mayParseFunctionExpressions = true;
    while (true) {
      Token next = token.next!;
      if (optional(')', next)) {
        token = next;
        break;
      }
      Token? colon = null;
      if (optional(':', next.next!)) {
        token =
            ensureIdentifier(token, IdentifierContext.namedArgumentReference)
                .next!;
        colon = token;
      }
      token = parseExpression(token);
      next = token.next!;
      if (colon != null) listener.handleNamedArgument(colon);
      ++argumentCount;
      if (!optional(',', next)) {
        if (optional(')', next)) {
          token = next;
          break;
        }
        // Recovery
        if (looksLikeExpressionStart(next)) {
          // If this looks like the start of an expression,
          // then report an error, insert the comma, and continue parsing.
          next = rewriteAndRecover(
              token,
              codes.templateExpectedButGot.withArguments(','),
              SyntheticToken(type: TokenType.COMMA, offset: next.offset));
        } else {
          token = ensureCloseParen(token, begin);
          break;
        }
      }
      token = next;
    }
    assert(optional(')', token));
    mayParseFunctionExpressions = old;
    listener.endArguments(argumentCount, begin, token);
    return token;
  }

  /// Returns true if [token] could be the start of a function declaration
  /// without a return type.
  bool looksLikeLocalFunction(Token token) {
    if (token.isIdentifier) {
      if (optional('<', token.next!)) {
        TypeParamOrArgInfo typeParam = computeTypeParamOrArg(token);
        if (typeParam == noTypeParamOrArg) {
          return false;
        }
        token = typeParam.skip(token);
      }
      token = token.next!;
      if (optional('(', token)) {
        token = token.endGroup!.next!;
        return optional('{', token) ||
            optional('=>', token) ||
            optional('async', token) ||
            optional('sync', token);
      } else if (optional('=>', token)) {
        // Recovery: Looks like a local function that is missing parenthesis.
        return true;
      }
    }
    return false;
  }

  /// Returns true if [token] could be the start of a function body.
  bool looksLikeFunctionBody(Token token) {
    return optional('{', token) || optional('=>', token);
  }

  /// This method has two modes based upon [onlyParseVariableDeclarationStart].
  ///
  /// If [onlyParseVariableDeclarationStart] is `false` (the default) then this
  /// method will parse a local variable declaration, a local function,
  /// or an expression statement, and then return the last consumed token.
  ///
  /// If [onlyParseVariableDeclarationStart] is `true` then this method
  /// will only parse the metadata, modifiers, and type of a local variable
  /// declaration if it exists. It is the responsibility of the caller to
  /// call [parseVariablesDeclarationRest] to finish parsing the local variable
  /// declaration. If a local variable declaration is not found then this
  /// method will return [start].
  Token parseExpressionStatementOrDeclaration(final Token start,
      [bool onlyParseVariableDeclarationStart = false]) {
    Token token = start;
    Token next = token.next!;

    Token? varFinalOrConst;

    if (optional('var', next)) {
      varFinalOrConst = token = token.next!;
      next = token.next!;
    }

    // Recovery
    ModifierRecoveryContext context = ModifierRecoveryContext(this)
      ..varFinalOrConst = varFinalOrConst;

    token = context.parseVariableDeclarationModifiers(token);
    next = token.next!;

    varFinalOrConst = context.varFinalOrConst;

    return parseExpressionStatementOrDeclarationAfterModifiers(
        token,
        start,
        varFinalOrConst,
        /* typeInfo = */ null,
        onlyParseVariableDeclarationStart);
  }

  /// See [parseExpressionStatementOrDeclaration]
  Token parseExpressionStatementOrDeclarationAfterModifiers(
      Token beforeType, Token start, Token? varFinalOrConst, TypeInfo? typeInfo,
      [bool onlyParseVariableDeclarationStart = false]) {
    // In simple cases check for bad 'late' modifier in non-nnbd-mode.
    if (typeInfo == null && varFinalOrConst == null && beforeType == start) {
      beforeType = start = beforeType.next!;

      // The below doesn't parse modifiers, so we need to do it here.
      ModifierRecoveryContext context = ModifierRecoveryContext(this);
      beforeType =
          start = context.parseVariableDeclarationModifiers(beforeType);
      varFinalOrConst = context.varFinalOrConst;
    }
    typeInfo ??= computeType(beforeType, /* required = */ false);

    Token token = typeInfo.skipType(beforeType);
    Token next = token.next!;

    if (looksLikeLocalFunction(next)) {
      // Parse a local function declaration.
      if (varFinalOrConst != null) {
        reportRecoverableErrorWithToken(
            varFinalOrConst, codes.templateExtraneousModifier);
      }
      Token beforeFormals =
          computeTypeParamOrArg(next).parseVariables(next, this);
      listener.beginLocalFunctionDeclaration(start.next!);
      token = typeInfo.parseType(beforeType, this);
      return parseNamedFunctionRest(
        token,
        start.next!,
        beforeFormals,
        /* isFunctionExpression = */ false,
      );
    }

    if (beforeType == start &&
        typeInfo.isNullable &&
        typeInfo.couldBeExpression) {
      assert(optional('?', token));
      assert(next.isKeywordOrIdentifier);
      if (!next.isIdentifier) {
        reportRecoverableError(
            next, codes.templateExpectedIdentifier.withArguments(next));
        next = rewriter.insertSyntheticIdentifier(next);
      }
      Token afterIdentifier = next.next!;
      //
      // found <typeref> `?` <identifier>
      // with no annotations or modifiers preceeding it
      //
      if (optional('=', afterIdentifier)) {
        //
        // look past the next expression
        // to determine if this is part of a conditional expression
        //
        Listener originalListener = listener;
        listener = ForwardingListener();
        // TODO(danrubel): consider using TokenStreamGhostWriter here
        Token afterExpression =
            parseExpressionWithoutCascade(afterIdentifier).next!;
        listener = originalListener;

        if (optional(':', afterExpression)) {
          // Looks like part of a conditional expression.
          // Drop the type information and reset the last consumed token.
          typeInfo = noType;
          token = start;
          next = token.next!;
        }
      } else if (!afterIdentifier.isKeyword &&
          !isOneOfOrEof(afterIdentifier, const [';', ',', ')'])) {
        // Looks like part of a conditional expression.
        // Drop the type information and reset the last consumed token.
        typeInfo = noType;
        token = start;
        next = token.next!;
      }
    }

    if (token == start) {
      // If no annotation, modifier, or type, and this is not a local function
      // then this must be an expression statement.
      if (onlyParseVariableDeclarationStart) {
        return start;
      } else {
        return parseExpressionStatement(start);
      }
    }

    if (next.type.isBuiltIn &&
        beforeType == start &&
        typeInfo.couldBeExpression) {
      // Detect expressions such as identifier `as` identifier
      // and treat those as expressions.
      if (optional('as', next) || optional('is', next)) {
        int kind = next.next!.kind;
        if (EQ_TOKEN != kind &&
            SEMICOLON_TOKEN != kind &&
            COMMA_TOKEN != kind) {
          return parseExpressionStatement(start);
        }
      }
    }

    if (next.isIdentifier) {
      // Only report these errors if there is an identifier. If there is not an
      // identifier, then allow ensureIdentifier to report an error
      // and don't report errors here.
      if (varFinalOrConst == null) {
        if (typeInfo == noType) {
          reportRecoverableError(next, codes.messageMissingConstFinalVarOrType);
        }
      } else if (optional('var', varFinalOrConst)) {
        if (typeInfo != noType) {
          reportRecoverableError(varFinalOrConst, codes.messageTypeAfterVar);
        }
      }
    }

    token = typeInfo.parseType(beforeType, this);
    next = token.next!;
    listener.beginVariablesDeclaration(next, varFinalOrConst);

    return token;
  }

  Token parseVariablesDeclarationRest(Token token, bool endWithSemicolon) {
    int count = 1;
    token = parseOptionallyInitializedIdentifier(token);
    while (optional(',', token.next!)) {
      token = parseOptionallyInitializedIdentifier(token.next!);
      ++count;
    }
    if (endWithSemicolon) {
      Token semicolon = ensureSemicolon(token);
      listener.endVariablesDeclaration(count, semicolon);
      return semicolon;
    } else {
      listener.endVariablesDeclaration(count, /* endToken = */ null);
      return token;
    }
  }

  Token parseOptionallyInitializedIdentifier(Token token) {
    Token nameToken =
        ensureIdentifier(token, IdentifierContext.localVariableDeclaration);
    listener.beginInitializedIdentifier(nameToken);
    token = parseVariableInitializerOpt(nameToken);
    listener.endInitializedIdentifier(nameToken);
    return token;
  }

  /// ```
  /// ifStatement:
  ///   'if' '(' expression ')' statement ('else' statement)?
  /// ;
  /// ```
  Token parseIfStatement(Token token) {
    Token ifToken = token.next!;
    assert(optional('if', ifToken));
    listener.beginIfStatement(ifToken);
    token = ensureParenthesizedCondition(ifToken);
    listener.beginThenStatement(token.next!);
    token = parseStatement(token);
    listener.endThenStatement(token);
    Token? elseToken = null;
    if (optional('else', token.next!)) {
      elseToken = token.next!;
      listener.beginElseStatement(elseToken);
      token = parseStatement(elseToken);
      listener.endElseStatement(elseToken);
    }
    listener.endIfStatement(ifToken, elseToken);
    return token;
  }

  /// ```
  /// forStatement:
  ///   'await'? 'for' '(' forLoopParts ')' statement
  /// ;
  ///
  ///  forLoopParts:
  ///      localVariableDeclaration ';' expression? ';' expressionList?
  ///    | expression? ';' expression? ';' expressionList?
  ///    | localVariableDeclaration 'in' expression
  ///    | identifier 'in' expression
  /// ;
  ///
  /// forInitializerStatement:
  ///   localVariableDeclaration |
  ///   expression? ';'
  /// ;
  /// ```
  Token parseForStatement(Token token, Token? awaitToken) {
    Token forToken = token = token.next!;
    assert(awaitToken == null || optional('await', awaitToken));
    assert(optional('for', token));
    listener.beginForStatement(forToken);

    token = parseForLoopPartsStart(awaitToken, forToken);
    Token identifier = token.next!;
    token = parseForLoopPartsMid(token, awaitToken, forToken);
    if (optional('in', token.next!) || optional(':', token.next!)) {
      // Process `for ( ... in ... )`
      return parseForInRest(token, awaitToken, forToken, identifier);
    } else {
      // Process `for ( ... ; ... ; ... )`
      return parseForRest(awaitToken, token, forToken);
    }
  }

  /// Parse the start of a for loop control structure
  /// from the open parenthesis up to but not including the identifier.
  Token parseForLoopPartsStart(Token? awaitToken, Token forToken) {
    Token leftParenthesis = forToken.next!;
    if (!optional('(', leftParenthesis)) {
      // Recovery
      reportRecoverableError(
          leftParenthesis, codes.templateExpectedButGot.withArguments('('));

      BeginToken openParen = rewriter.insertToken(
          forToken,
          SyntheticToken(
              type: TokenType.OPEN_PAREN,
              offset: leftParenthesis.offset)) as BeginToken;

      Token token;
      if (awaitToken != null) {
        token = rewriter.insertSyntheticIdentifier(openParen);
        token = rewriter.insertSyntheticKeyword(token, Keyword.IN);
        token = rewriter.insertSyntheticIdentifier(token);
      } else {
        token = rewriter.insertSyntheticToken(openParen, TokenType.SEMICOLON);
        token = rewriter.insertSyntheticToken(token, TokenType.SEMICOLON);
      }

      openParen.endGroup = token = rewriter.insertToken(
          token,
          SyntheticToken(
              type: TokenType.CLOSE_PAREN, offset: leftParenthesis.offset));

      token = rewriter.insertSyntheticIdentifier(token);
      rewriter.insertSyntheticToken(token, TokenType.SEMICOLON);

      leftParenthesis = openParen;
    }

    // Pass `true` so that the [parseExpressionStatementOrDeclaration] only
    // parses the metadata, modifiers, and type of a local variable
    // declaration if it exists. This enables capturing [beforeIdentifier]
    // for later error reporting.
    return parseExpressionStatementOrDeclaration(
        leftParenthesis, /* onlyParseVariableDeclarationStart = */ true);
  }

  /// Parse the remainder of the local variable declaration
  /// or an expression if no local variable declaration was found.
  Token parseForLoopPartsMid(Token token, Token? awaitToken, Token forToken) {
    if (token != forToken.next) {
      token =
          parseVariablesDeclarationRest(token, /* endWithSemicolon = */ false);
      listener.handleForInitializerLocalVariableDeclaration(
          token, optional('in', token.next!) || optional(':', token.next!));
    } else if (optional(';', token.next!)) {
      listener.handleForInitializerEmptyStatement(token.next!);
    } else {
      token = parseExpression(token);
      listener.handleForInitializerExpressionStatement(
          token,
          optional('in', token.next!) ||
              optional(':', token.next!) ||
              // If this is an empty `await for`, we rewrite it into an
              // `await for (_ in _)`.
              (awaitToken != null && optional(')', token.next!)));
    }
    Token next = token.next!;
    if (optional(';', next)) {
      if (awaitToken != null) {
        reportRecoverableError(awaitToken, codes.messageInvalidAwaitFor);
      }
    } else if (!optional('in', next)) {
      // Recovery
      if (optional(':', next)) {
        reportRecoverableError(next, codes.messageColonInPlaceOfIn);
      } else if (awaitToken != null) {
        reportRecoverableError(
            next, codes.templateExpectedButGot.withArguments('in'));
        token.setNext(
            SyntheticKeywordToken(keyword: Keyword.IN, offset: next.offset)
              ..setNext(next));
      }
    }
    return token;
  }

  /// This method parses the portion of the forLoopParts that starts with the
  /// first semicolon (the one that terminates the forInitializerStatement).
  ///
  /// ```
  ///  forLoopParts:
  ///      localVariableDeclaration ';' expression? ';' expressionList?
  ///    | expression? ';' expression? ';' expressionList?
  ///    | localVariableDeclaration 'in' expression
  ///    | identifier 'in' expression
  /// ;
  /// ```
  Token parseForRest(Token? awaitToken, Token token, Token forToken) {
    token = parseForLoopPartsRest(token, forToken, awaitToken);
    listener.beginForStatementBody(token.next!);
    LoopState savedLoopState = loopState;
    loopState = LoopState.InsideLoop;
    token = parseStatement(token);
    loopState = savedLoopState;
    listener.endForStatementBody(token.next!);
    listener.endForStatement(token.next!);
    return token;
  }

  Token parseForLoopPartsRest(Token token, Token forToken, Token? awaitToken) {
    Token leftParenthesis = forToken.next!;
    assert(optional('for', forToken));
    assert(optional('(', leftParenthesis));

    Token leftSeparator = ensureSemicolon(token);
    if (optional(';', leftSeparator.next!)) {
      token = parseEmptyStatement(leftSeparator);
    } else {
      token = parseExpressionStatement(leftSeparator);
    }
    int expressionCount = 0;
    while (true) {
      Token next = token.next!;
      if (optional(')', next)) {
        token = next;
        break;
      }
      token = parseExpression(token).next!;
      ++expressionCount;
      if (!optional(',', token)) {
        break;
      }
    }
    if (token != leftParenthesis.endGroup) {
      reportRecoverableErrorWithToken(token, codes.templateUnexpectedToken);
      token = leftParenthesis.endGroup!;
    }
    listener.handleForLoopParts(
        forToken, leftParenthesis, leftSeparator, expressionCount);
    return token;
  }

  /// This method parses the portion of the forLoopParts that starts with the
  /// keyword 'in'. For the sake of recovery, we accept a colon in place of the
  /// keyword.
  ///
  /// ```
  ///  forLoopParts:
  ///      localVariableDeclaration ';' expression? ';' expressionList?
  ///    | expression? ';' expression? ';' expressionList?
  ///    | localVariableDeclaration 'in' expression
  ///    | identifier 'in' expression
  /// ;
  /// ```
  Token parseForInRest(
      Token token, Token? awaitToken, Token forToken, Token identifier) {
    token = parseForInLoopPartsRest(token, awaitToken, forToken, identifier);
    listener.beginForInBody(token.next!);
    LoopState savedLoopState = loopState;
    loopState = LoopState.InsideLoop;
    token = parseStatement(token);
    loopState = savedLoopState;
    listener.endForInBody(token.next!);
    listener.endForIn(token.next!);
    return token;
  }

  Token parseForInLoopPartsRest(
      Token token, Token? awaitToken, Token forToken, Token identifier) {
    Token inKeyword = token.next!;
    assert(optional('for', forToken));
    assert(optional('(', forToken.next!));
    assert(optional('in', inKeyword) || optional(':', inKeyword));

    if (!identifier.isIdentifier) {
      // TODO(jensj): This should probably (sometimes) be
      // templateExpectedIdentifierButGotKeyword instead.
      reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifier);
    } else if (identifier != token) {
      if (optional('=', identifier.next!)) {
        reportRecoverableError(
            identifier.next!, codes.messageInitializedVariableInForEach);
      } else {
        reportRecoverableErrorWithToken(
            identifier.next!, codes.templateUnexpectedToken);
      }
    }

    listener.beginForInExpression(inKeyword.next!);
    token = parseExpression(inKeyword);
    token = ensureCloseParen(token, forToken.next!);
    listener.endForInExpression(token);
    listener.handleForInLoopParts(
        awaitToken, forToken, forToken.next!, inKeyword);
    return token;
  }

  /// ```
  /// whileStatement:
  ///   'while' '(' expression ')' statement
  /// ;
  /// ```
  Token parseWhileStatement(Token token) {
    Token whileToken = token.next!;
    assert(optional('while', whileToken));
    listener.beginWhileStatement(whileToken);
    token = ensureParenthesizedCondition(whileToken);
    listener.beginWhileStatementBody(token.next!);
    LoopState savedLoopState = loopState;
    loopState = LoopState.InsideLoop;
    token = parseStatement(token);
    loopState = savedLoopState;
    listener.endWhileStatementBody(token.next!);
    listener.endWhileStatement(whileToken, token.next!);
    return token;
  }

  /// ```
  /// doStatement:
  ///   'do' statement 'while' '(' expression ')' ';'
  /// ;
  /// ```
  Token parseDoWhileStatement(Token token) {
    Token doToken = token.next!;
    assert(optional('do', doToken));
    listener.beginDoWhileStatement(doToken);
    listener.beginDoWhileStatementBody(doToken.next!);
    LoopState savedLoopState = loopState;
    loopState = LoopState.InsideLoop;
    token = parseStatement(doToken);
    loopState = savedLoopState;
    listener.endDoWhileStatementBody(token);
    Token whileToken = token.next!;
    if (!optional('while', whileToken)) {
      reportRecoverableError(
          whileToken, codes.templateExpectedButGot.withArguments('while'));
      whileToken = rewriter.insertSyntheticKeyword(token, Keyword.WHILE);
    }
    token = ensureParenthesizedCondition(whileToken);
    token = ensureSemicolon(token);
    listener.endDoWhileStatement(doToken, whileToken, token);
    return token;
  }

  /// ```
  /// block:
  ///   '{' statement* '}'
  /// ;
  /// ```
  Token parseBlock(Token token, BlockKind blockKind) {
    Token begin = token =
        ensureBlock(token, /* template = */ null, blockKind.missingBlockName);
    listener.beginBlock(begin, blockKind);
    int statementCount = 0;
    Token startToken = token.next!;
    while (notEofOrValue('}', startToken)) {
      token = parseStatement(token);
      if (identical(token.next!, startToken)) {
        // No progress was made, so we report the current token as being invalid
        // and move forward.
        token = token.next!;
        reportRecoverableError(
            token, codes.templateUnexpectedToken.withArguments(token));
      }
      ++statementCount;
      startToken = token.next!;
    }
    token = token.next!;
    assert(token.isEof || optional('}', token));
    listener.endBlock(statementCount, begin, token, blockKind);
    return token;
  }

  Token parseInvalidBlock(Token token) {
    Token begin = token.next!;
    assert(optional('{', begin));
    // Parse and report the invalid block, but suppress errors
    // because an error has already been reported by the caller.
    Listener originalListener = listener;
    listener = ForwardingListener(listener)..forwardErrors = false;
    // The scanner ensures that `{` always has a closing `}`.
    token = parseBlock(token, BlockKind.invalid);
    listener = originalListener;
    listener.handleInvalidTopLevelBlock(begin);
    return token;
  }

  /// Determine if the following tokens look like an expression and not a local
  /// variable or local function declaration.
  bool looksLikeExpression(Token token) {
    // TODO(srawlins): Consider parsing the potential expression once doing so
    //  does not modify the token stream. For now, use simple look ahead and
    //  ensure no false positives.

    token = token.next!;
    if (token.isIdentifier) {
      token = token.next!;
      if (optional('(', token)) {
        token = token.endGroup!.next!;
        if (isOneOf(token, [';', '.', '..', '?', '?.'])) {
          return true;
        }
      } else if (isOneOf(token, ['.', ')', ']'])) {
        // TODO(srawlins): Also consider when `token` is `;`. There is still not
        // good error recovery on `yield x;`. This would also require
        // modification to analyzer's
        // test_parseCompilationUnit_pseudo_asTypeName.
        return true;
      }
    } else if (token == Keyword.NULL) {
      return true;
    }
    // TODO(srawlins): Consider other possibilities for `token` which would
    //  imply it looks like an expression, for example beginning with `<`, as
    //  part of a collection literal type argument list, `(`, other literals,
    //  etc. For example, there is still not good error recovery on
    //  `yield <int>[]`.

    return false;
  }

  /// ```
  /// switchStatement:
  ///   'switch' parenthesizedExpression switchBlock
  /// ;
  /// ```
  Token parseSwitchStatement(Token token) {
    Token switchKeyword = token.next!;
    assert(optional('switch', switchKeyword));
    listener.beginSwitchStatement(switchKeyword);
    token = ensureParenthesizedCondition(switchKeyword);
    LoopState savedLoopState = loopState;
    if (loopState == LoopState.OutsideLoop) {
      loopState = LoopState.InsideSwitch;
    }
    token = parseSwitchBlock(token);
    loopState = savedLoopState;
    listener.endSwitchStatement(switchKeyword, token);
    return token;
  }

  /// ```
  /// switchBlock:
  ///   '{' switchCase* defaultCase? '}'
  /// ;
  /// ```
  Token parseSwitchBlock(Token token) {
    Token beginSwitch =
        token = ensureBlock(token, /* template = */ null, 'switch statement');
    listener.beginSwitchBlock(beginSwitch);
    int caseCount = 0;
    Token? defaultKeyword = null;
    Token? colonAfterDefault = null;
    while (notEofOrValue('}', token.next!)) {
      Token beginCase = token.next!;
      int expressionCount = 0;
      int labelCount = 0;
      Token peek = peekPastLabels(beginCase);
      while (true) {
        // Loop until we find something that can't be part of a switch case.
        String? value = peek.toString();
        if (identical(value, 'default')) {
          while (!identical(token.next!, peek)) {
            token = parseLabel(token);
            labelCount++;
          }
          if (defaultKeyword != null) {
            reportRecoverableError(
                token.next!, codes.messageSwitchHasMultipleDefaults);
          }
          defaultKeyword = token.next!;
          colonAfterDefault = token = ensureColon(defaultKeyword);
          peek = token.next!;
          break;
        } else if (identical(value, 'case')) {
          while (!identical(token.next!, peek)) {
            token = parseLabel(token);
            labelCount++;
          }
          Token caseKeyword = token.next!;
          if (defaultKeyword != null) {
            reportRecoverableError(
                caseKeyword, codes.messageSwitchHasCaseAfterDefault);
          }
          listener.beginCaseExpression(caseKeyword);
          token = parseExpression(caseKeyword);
          token = ensureColon(token);
          listener.endCaseExpression(token);
          listener.handleCaseMatch(caseKeyword, token);
          expressionCount++;
          peek = peekPastLabels(token.next!);
        } else if (expressionCount > 0) {
          break;
        } else {
          // Recovery
          reportRecoverableError(
              peek, codes.templateExpectedToken.withArguments("case"));
          Token endGroup = beginSwitch.endGroup!;
          while (token.next != endGroup) {
            token = token.next!;
          }
          peek = peekPastLabels(token.next!);
          break;
        }
      }
      token = parseStatementsInSwitchCase(token, peek, beginCase, labelCount,
          expressionCount, defaultKeyword, colonAfterDefault);
      ++caseCount;
    }
    token = token.next!;
    listener.endSwitchBlock(caseCount, beginSwitch, token);
    assert(token.isEof || optional('}', token));
    return token;
  }

  /// Peek after the following labels (if any). The following token
  /// is used to determine if the labels belong to a statement or a
  /// switch case.
  Token peekPastLabels(Token token) {
    while (token.isIdentifier && optional(':', token.next!)) {
      token = token.next!.next!;
    }
    return token;
  }

  /// Parse statements after a switch `case:` or `default:`.
  Token parseStatementsInSwitchCase(
      Token token,
      Token peek,
      Token begin,
      int labelCount,
      int expressionCount,
      Token? defaultKeyword,
      Token? colonAfterDefault) {
    listener.beginSwitchCase(labelCount, expressionCount, begin);
    // Finally zero or more statements.
    int statementCount = 0;
    while (!identical(token.next!.kind, EOF_TOKEN)) {
      String? value = peek.toString();
      if ((identical(value, 'case')) ||
          (identical(value, 'default')) ||
          ((identical(value, '}')) && (identical(token.next!, peek)))) {
        // A label just before "}" will be handled as a statement error.
        break;
      } else {
        Token startToken = token.next!;
        token = parseStatement(token);
        Token next = token.next!;
        if (identical(next, startToken)) {
          // No progress was made, so we report the current token as being
          // invalid and move forward.
          reportRecoverableError(
              next, codes.templateUnexpectedToken.withArguments(next));
          token = next;
        }
        ++statementCount;
      }
      peek = peekPastLabels(token.next!);
    }
    listener.endSwitchCase(labelCount, expressionCount, defaultKeyword,
        colonAfterDefault, statementCount, begin, token.next!);
    return token;
  }

  /// ```
  /// breakStatement:
  ///   'break' identifier? ';'
  /// ;
  /// ```
  Token parseBreakStatement(Token token) {
    Token breakKeyword = token = token.next!;
    assert(optional('break', breakKeyword));
    bool hasTarget = false;
    if (token.next!.isIdentifier) {
      token = ensureIdentifier(token, IdentifierContext.labelReference);
      hasTarget = true;
    } else if (!isBreakAllowed) {
      reportRecoverableError(breakKeyword, codes.messageBreakOutsideOfLoop);
    }
    token = ensureSemicolon(token);
    listener.handleBreakStatement(hasTarget, breakKeyword, token);
    return token;
  }

  /// ```
  /// continueStatement:
  ///   'continue' identifier? ';'
  /// ;
  /// ```
  Token parseContinueStatement(Token token) {
    Token continueKeyword = token = token.next!;
    assert(optional('continue', continueKeyword));
    bool hasTarget = false;
    if (token.next!.isIdentifier) {
      token = ensureIdentifier(token, IdentifierContext.labelReference);
      hasTarget = true;
      if (!isContinueWithLabelAllowed) {
        reportRecoverableError(
            continueKeyword, codes.messageContinueOutsideOfLoop);
      }
    } else if (!isContinueAllowed) {
      reportRecoverableError(
          continueKeyword,
          loopState == LoopState.InsideSwitch
              ? codes.messageContinueWithoutLabelInCase
              : codes.messageContinueOutsideOfLoop);
    }
    token = ensureSemicolon(token);
    listener.handleContinueStatement(hasTarget, continueKeyword, token);
    return token;
  }

  /// ```
  /// emptyStatement:
  ///   ';'
  /// ;
  /// ```
  Token parseEmptyStatement(Token token) {
    token = token.next!;
    assert(optional(';', token));
    listener.handleEmptyStatement(token);
    return token;
  }

  /// Given a token ([beforeToken]) that is known to be before another [token],
  /// return the token that is immediately before the [token].
  Token previousToken(Token beforeToken, Token token) {
    Token next = beforeToken.next!;
    while (next != token && next != beforeToken) {
      beforeToken = next;
      next = beforeToken.next!;
    }
    return beforeToken;
  }

  /// Report that the nesting depth of the code being parsed is too large for
  /// the parser to safely handle. Return the next `}` or EOF.
  Token recoverFromStackOverflow(Token token) {
    Token next = token.next!;
    reportRecoverableError(next, codes.messageStackOverflow);
    next = rewriter.insertSyntheticToken(token, TokenType.SEMICOLON);
    listener.handleEmptyStatement(next);

    while (notEofOrValue('}', next)) {
      token = next;
      next = token.next!;
    }
    return token;
  }

  void reportRecoverableError(Token token, codes.Message message) {
    // Find a non-synthetic token on which to report the error.
    token = findNonZeroLengthToken(token);
    listener.handleRecoverableError(message, token, token);
  }

  void reportRecoverableErrorWithEnd(
      Token startToken, Token endToken, codes.Message message) {
    listener.handleRecoverableError(message, startToken, endToken);
  }

  void reportRecoverableErrorWithToken(
      Token token, codes.Template<_MessageWithArgument<Token>> template) {
    // Find a non-synthetic token on which to report the error.
    token = findNonZeroLengthToken(token);
    listener.handleRecoverableError(
        template.withArguments(token), token, token);
  }

  Token reportAllErrorTokens(Token token) {
    while (token is ErrorToken) {
      listener.handleErrorToken(token);
      token = token.next!;
    }
    return token;
  }

  Token skipErrorTokens(Token token) {
    while (token is ErrorToken) {
      token = token.next!;
    }
    return token;
  }

  Token parseInvalidTopLevelDeclaration(Token token) {
    Token next = token.next!;
    reportRecoverableErrorWithToken(
        next,
        optional(';', next)
            ? codes.templateUnexpectedToken
            : codes.templateExpectedDeclaration);
    if (optional('{', next)) {
      next = parseInvalidBlock(token);
    }
    listener.handleInvalidTopLevelDeclaration(next);
    return next;
  }

  Token reportAndSkipClassInClass(Token token) {
    assert(optional('class', token));
    reportRecoverableError(token, codes.messageClassInClass);
    listener.handleInvalidMember(token);
    Token next = token.next!;
    // If the declaration appears to be a valid class declaration
    // then skip the entire declaration so that we only generate the one
    // error (above) rather than a plethora of unhelpful errors.
    if (next.isIdentifier) {
      // skip class name
      token = next;
      next = token.next!;
      // TODO(danrubel): consider parsing (skipping) the class header
      // with a recovery listener so that no events are generated
      if (optional('{', next) && next.endGroup != null) {
        // skip class body
        token = next.endGroup!;
      }
    }
    listener.endMember();
    return token;
  }

  Token reportAndSkipTypedefInClass(Token token) {
    assert(optional('typedef', token));
    reportRecoverableError(token, codes.messageTypedefInClass);
    listener.handleInvalidMember(token);
    // TODO(brianwilkerson): If the declaration appears to be a valid typedef
    // then skip the entire declaration so that we generate a single error
    // (above) rather than many unhelpful errors.
    listener.endMember();
    return token;
  }

  /// Create a short token chain from the [beginToken] and [endToken] and return
  /// the [beginToken].
  Token link(BeginToken beginToken, Token endToken) {
    beginToken.setNext(endToken);
    beginToken.endGroup = endToken;
    return beginToken;
  }

  /// Create and return a token whose next token is the given [token].
  Token syntheticPreviousToken(Token token) {
    // Return the previous token if there is one so that any token inserted
    // before `token` will be properly inserted into the token stream.
    // TODO(danrubel): remove this once all methods have been converted to
    // use and return the last token consumed and the `previous` field
    // has been removed.
    if (token.previous != null) {
      return token.previous!;
    }
    Token before = SimpleToken.eof(/* offset = */ -1);
    before.next = token;
    return before;
  }

  Token? findDartDoc(Token token) {
    Token? comments = token.precedingComments;
    Token? dartdoc = null;
    bool isMultiline = false;
    while (comments != null) {
      String lexeme = comments.lexeme;
      if (lexeme.startsWith('///')) {
        if (!isMultiline) {
          dartdoc = comments;
          isMultiline = true;
        }
      } else if (lexeme.startsWith('/**')) {
        dartdoc = comments;
        isMultiline = false;
      }
      comments = comments.next;
    }
    return dartdoc;
  }
}

// TODO(ahe): Remove when analyzer supports generalized function syntax.
typedef _MessageWithArgument<T> = codes.Message Function(T);
