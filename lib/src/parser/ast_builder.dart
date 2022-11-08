// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast_impl/ast.dart';
import 'package:dartfx/src/lexer/tokens/error_token.dart';
import 'package:dartfx/src/lexer/tokens/keyword_token.dart';
import 'package:dartfx/src/lexer/tokens/string_token.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:dartfx/src/lexer/tokens/token_constants.dart';
import '../messages/codes.dart'
    show
        Code,
        LocatedMessage,
        Message,
        messageDirectiveAfterDeclaration,
        messageExpectedStatement,
        messageFieldInitializerOutsideConstructor,
        messageIllegalAssignmentToNonAssignable,
        messageMissingAssignableSelector,
        messageNativeClauseShouldBeAnnotation,
        messagePositionalAfterNamedArgument,
        templateDuplicateLabelInSwitchStatement,
        templateExpectedButGot,
        templateExpectedIdentifier,
        templateInternalProblemUnhandled,
        templateUnexpectedToken;
import '../ast_impl/ast_factory.dart';
import 'block_kind.dart';
import 'error_converter.dart';
import 'formal_parameter_kind.dart';
import 'identifier_context.dart';
import 'member_kind.dart';
import 'parser.dart';
import 'quote.dart';
import 'stack_listener.dart';
import 'util.dart';

const _invalidCollectionElement = _InvalidCollectionElement._();

/// A parser listener that builds the analyzer's AST structure.
class AstBuilder extends StackListener {
  final AstFactoryImpl ast = astFactory;

  final FastaErrorReporter errorReporter;
  ScriptTag? scriptTag;
  final List<Directive> directives = <Directive>[];
  final List<CompilationUnitMember> declarations = <CompilationUnitMember>[];

  /// The parser that uses this listener, used to parse optional parts, e.g.
  /// `native` support.
  late Parser parser;

  /// If true, this is building a full AST. Otherwise, only create method
  /// bodies.
  final bool isFullAst;

  /// `true` if the `native` clause is allowed
  /// in class, method, and function declarations.
  ///
  /// This is being replaced by the @native(...) annotation.
  //
  // TODO(danrubel) Move this flag to a better location
  // and should only be true if either:
  // * The current library is a platform library
  // * The current library has an import that uses the scheme "dart-ext".
  bool allowNativeClause = false;

  StringLiteral? nativeName;

  bool parseFunctionBodies = true;

  /// `true` if named arguments anywhere are enabled
  final bool enableNamedArgumentsAnywhere = true;

  AstBuilder(ErrorReporter? errorReporter, this.isFullAst)
      : errorReporter = FastaErrorReporter(errorReporter);

  @override
  void addProblem(Message message, int charOffset, int length,
      {bool wasHandled = false, List<LocatedMessage>? context}) {
    if (directives.isEmpty &&
        (message.code.analyzerCodes
                ?.contains('NON_PART_OF_DIRECTIVE_IN_PART') ??
            false)) {
      message = messageDirectiveAfterDeclaration;
    }
    errorReporter.reportMessage(message, charOffset, length);
  }

  @override
  void beginCompilationUnit(Token token) {
    push(token);
  }

  @override
  void beginFormalParameter(Token token, MemberKind kind, Token? requiredToken,
      Token? covariantToken, Token? varFinalOrConst) {
    push(_Modifiers()..finalConstOrVarKeyword = varFinalOrConst);
  }

  @override
  void beginFormalParameterDefaultValueExpression() {}

  @override
  void beginIfControlFlow(Token ifToken) {
    push(ifToken);
  }

  @override
  void beginLiteralString(Token literalString) {
    assert(identical(literalString.kind, STRING_TOKEN));
    debugEvent("beginLiteralString");

    push(literalString);
  }

  @override
  void beginProgram(Token token) {
    push(token);
  }

  @override
  void beginTopLevelMethod(Token lastConsumed, Token? externalToken) {
    push(_Modifiers());
  }

  @override
  void beginVariablesDeclaration(Token token, Token? varFinalOrConst) {
    debugEvent("beginVariablesDeclaration");
    if (varFinalOrConst != null) {
      push(_Modifiers()..finalConstOrVarKeyword = varFinalOrConst);
    } else {
      push(NullValue.Modifiers);
    }
  }

  void checkFieldFormalParameters(FormalParameterList? parameterList) {
    var parameters = parameterList?.parameters;
    if (parameters != null) {
      parameters.forEach((FormalParameter param) {
        if (param is FieldFormalParameter) {
          // This error is reported in the BodyBuilder.endFormalParameter.
          handleRecoverableError(messageFieldInitializerOutsideConstructor,
              param.thisKeyword, param.thisKeyword);
        }
      });
    }
  }

  @override
  void debugEvent(String name) {
    // printEvent('AstBuilder: $name');
  }

  void doDotExpression(Token dot) {
    var identifierOrInvoke = pop() as Expression;
    var receiver = pop() as Expression?;
    if (identifierOrInvoke is SimpleIdentifier) {
      if (receiver is SimpleIdentifier && identical('.', dot.toString())) {
        push(ast.prefixedIdentifier(receiver, dot, identifierOrInvoke));
      } else {
        push(ast.propertyAccess(receiver, dot, identifierOrInvoke));
      }
    } else if (identifierOrInvoke is MethodInvocationImpl) {
      assert(identifierOrInvoke.target == null);
      identifierOrInvoke
        ..target = receiver
        ..operator = dot;
      push(identifierOrInvoke);
    } else {
      // This same error is reported in BodyBuilder.doDotOrCascadeExpression
      Token token = identifierOrInvoke.beginToken;
      // TODO(danrubel): Consider specializing the error message based
      // upon the type of expression. e.g. "x.this" -> templateThisAsIdentifier
      handleRecoverableError(
          templateExpectedIdentifier.withArguments(token), token, token);
      SimpleIdentifier identifier =
          ast.simpleIdentifier(token, isDeclaration: false);
      push(ast.propertyAccess(receiver, dot, identifier));
    }
  }

  void doInvocation(
      TypeArgumentList? typeArguments, MethodInvocationImpl arguments) {
    var receiver = pop() as Expression;
    if (receiver is SimpleIdentifierImpl) {
      arguments.methodName = receiver;
      if (typeArguments != null) {
        arguments.typeArguments = typeArguments;
      }
      push(arguments);
    } else {
      push(ast.functionExpressionInvocation(
          receiver, typeArguments, arguments.argumentList));
    }
  }

  void doPropertyGet() {}

  @override
  void endArguments(int count, Token leftParenthesis, Token rightParenthesis) {
    assert(optional('(', leftParenthesis));
    assert(optional(')', rightParenthesis));
    debugEvent("Arguments");

    var expressions = popTypedList2<Expression>(count);
    ArgumentList arguments =
        ast.argumentList(leftParenthesis, expressions, rightParenthesis);

    if (!enableNamedArgumentsAnywhere) {
      bool hasSeenNamedArgument = false;
      for (Expression expression in expressions) {
        if (expression is NamedExpression) {
          hasSeenNamedArgument = true;
        } else if (hasSeenNamedArgument) {
          // Positional argument after named argument.
          handleRecoverableError(messagePositionalAfterNamedArgument,
              expression.beginToken, expression.endToken);
        }
      }
    }

    push(ast.methodInvocation(
        null, null, _tmpSimpleIdentifier(), null, arguments));
  }

  @override
  void endBinaryExpression(Token operatorToken) {
    assert(operatorToken.isOperator ||
        optional('.', operatorToken) ||
        optional('?.', operatorToken) ||
        optional('..', operatorToken) ||
        optional('?..', operatorToken) ||
        optional('===', operatorToken) ||
        optional('!==', operatorToken));
    debugEvent("BinaryExpression");

    if (identical(".", operatorToken.toString()) ||
        identical("?.", operatorToken.toString()) ||
        identical("..", operatorToken.toString()) ||
        identical("?..", operatorToken.toString())) {
      doDotExpression(operatorToken);
    } else {
      var right = pop() as Expression;
      var left = pop() as Expression;
      push(ast.binaryExpression(left, operatorToken, right));
    }
  }

  @override
  void endBlock(
      int count, Token leftBracket, Token rightBracket, BlockKind blockKind) {
    assert(optional('{', leftBracket));
    assert(optional('}', rightBracket));
    debugEvent("Block");

    var statements = popTypedList2<Statement>(count);
    push(ast.block(leftBracket, statements, rightBracket));
  }

  @override
  void endBlockFunctionBody(int count, Token leftBracket, Token rightBracket) {
    assert(optional('{', leftBracket));
    assert(optional('}', rightBracket));
    debugEvent("BlockFunctionBody");

    var statements = popTypedList2<Statement>(count);
    Block block = ast.block(leftBracket, statements, rightBracket);
    var star = pop() as Token?;
    var asyncKeyword = pop() as Token?;
    if (parseFunctionBodies) {
      push(ast.blockFunctionBody(asyncKeyword, star, block));
    }
  }

  @override
  void endCombinators(int count) {
    debugEvent("Combinators");
    push(popTypedList<Combinator>(count) ?? NullValue.Combinators);
  }

  @override
  void endCompilationUnit(int count, Token endToken) {
    debugEvent("CompilationUnit");

    var beginToken = pop() as Token;
    checkEmpty(endToken.charOffset);

    CompilationUnitImpl unit = ast.compilationUnit(
      beginToken: beginToken,
      scriptTag: scriptTag,
      directives: directives,
      declarations: declarations,
      endToken: endToken,
    );
    push(unit);
  }

  @override
  void endConditionalExpression(Token question, Token colon) {
    assert(optional('?', question));
    assert(optional(':', colon));
    debugEvent("ConditionalExpression");

    var elseExpression = pop() as Expression;
    var thenExpression = pop() as Expression;
    var condition = pop() as Expression;
    push(ast.conditionalExpression(
        condition, question, thenExpression, colon, elseExpression));
  }

  @override
  void endConstLiteral(Token token) {
    debugEvent("endConstLiteral");
  }

  @override
  void endDoWhileStatement(
      Token doKeyword, Token whileKeyword, Token semicolon) {
    assert(optional('do', doKeyword));
    assert(optional('while', whileKeyword));
    assert(optional(';', semicolon));
    debugEvent("DoWhileStatement");

    var condition = pop() as ParenthesizedExpression;
    var body = pop() as Statement;
    push(ast.doStatement(
        doKeyword,
        body,
        whileKeyword,
        condition.leftParenthesis,
        condition.expression,
        condition.rightParenthesis,
        semicolon));
  }

  @override
  void endDoWhileStatementBody(Token token) {
    debugEvent("endDoWhileStatementBody");
  }

  @override
  void endElseStatement(Token token) {
    debugEvent("endElseStatement");
  }

  @override
  void endForControlFlow(Token token) {
    debugEvent("endForControlFlow");
    var entry = pop() as Object;
    var forLoopParts = pop() as ForParts;
    var leftParen = pop() as Token;
    var forToken = pop() as Token;

    pushForControlFlowInfo(forToken, leftParen, forLoopParts, entry);
  }

  @override
  void endForIn(Token endToken) {
    debugEvent("ForInExpression");

    var body = pop() as Statement;
    var forLoopParts = pop() as ForEachParts;
    var leftParenthesis = pop() as Token;
    var forToken = pop() as Token;
    var awaitToken = pop(NullValue.AwaitToken) as Token?;

    push(ast.forStatement(
      awaitKeyword: awaitToken,
      forKeyword: forToken,
      leftParenthesis: leftParenthesis,
      forLoopParts: forLoopParts,
      rightParenthesis: leftParenthesis.endGroup!,
      body: body,
    ));
  }

  @override
  void endForInBody(Token token) {
    debugEvent("endForInBody");
  }

  @override
  void endForInControlFlow(Token token) {
    debugEvent("endForInControlFlow");

    var entry = pop() as Object;
    var forLoopParts = pop() as ForEachParts;
    var leftParenthesis = pop() as Token;
    var forToken = pop() as Token;

    pushForControlFlowInfo(forToken, leftParenthesis, forLoopParts, entry);
  }

  @override
  void endForInExpression(Token token) {
    debugEvent("ForInExpression");
  }

  @override
  void endFormalParameter(Token nameToken, Token? initializerStart,
      Token? initializerEnd, FormalParameterKind kind, MemberKind memberKind) {
    debugEvent("FormalParameter");

    var defaultValue = pop() as _ParameterDefaultValue?;
    var name = pop() as SimpleIdentifier?;
    var typeOrFunctionTypedParameter = pop() as AstNode?;
    var modifiers = pop() as _Modifiers?;
    var keyword = modifiers?.finalConstOrVarKeyword;

    NormalFormalParameter node;
    if (typeOrFunctionTypedParameter is FunctionTypedFormalParameter) {
      // This is a temporary AST node that was constructed in
      // [endFunctionTypedFormalParameter]. We now deconstruct it and create
      // the final AST node.

      node = ast.functionTypedFormalParameter2(
          identifier: name!,
          returnType: typeOrFunctionTypedParameter.returnType,
          typeParameters: typeOrFunctionTypedParameter.typeParameters,
          parameters: typeOrFunctionTypedParameter.parameters,
          question: typeOrFunctionTypedParameter.question);
    } else {
      var type = typeOrFunctionTypedParameter as TypeAnnotation?;

      node = ast.simpleFormalParameter2(
          keyword: keyword, type: type, identifier: name);
    }

    ParameterKind analyzerKind = _toAnalyzerParameterKind(kind, null);
    FormalParameter parameter = node;
    if (analyzerKind != ParameterKind.REQUIRED) {
      parameter = ast.defaultFormalParameter(
          node, analyzerKind, defaultValue?.separator, defaultValue?.value);
    } else if (defaultValue != null) {
      // An error is reported if a required parameter has a default value.
      // Record it as named parameter for recovery.
      parameter = ast.defaultFormalParameter(node, ParameterKind.NAMED,
          defaultValue.separator, defaultValue.value);
    }
    push(parameter);
  }

  @override
  void endFormalParameterDefaultValueExpression() {
    debugEvent("FormalParameterDefaultValueExpression");
  }

  @override
  void endFormalParameters(
      int count, Token leftParen, Token rightParen, MemberKind kind) {
    assert(optional('(', leftParen));
    assert(optional(')', rightParen));
    debugEvent("FormalParameters");

    var rawParameters = popTypedList(count) ?? const <Object>[];
    List<FormalParameter> parameters = <FormalParameter>[];
    Token? leftDelimiter;
    Token? rightDelimiter;
    for (Object raw in rawParameters) {
      if (raw is _OptionalFormalParameters) {
        parameters.addAll(raw.parameters ?? const <FormalParameter>[]);
        leftDelimiter = raw.leftDelimiter;
        rightDelimiter = raw.rightDelimiter;
      } else {
        parameters.add(raw as FormalParameter);
      }
    }
    push(ast.formalParameterList(
        leftParen, parameters, leftDelimiter, rightDelimiter, rightParen));
  }

  @override
  void endForStatement(Token endToken) {
    debugEvent("ForStatement");
    var body = pop() as Statement;
    var forLoopParts = pop() as ForParts;
    var leftParen = pop() as Token;
    var forToken = pop() as Token;

    push(ast.forStatement(
      forKeyword: forToken,
      leftParenthesis: leftParen,
      forLoopParts: forLoopParts,
      rightParenthesis: leftParen.endGroup!,
      body: body,
    ));
  }

  @override
  void endForStatementBody(Token token) {
    debugEvent("endForStatementBody");
  }

  @override
  void endFunctionExpression(Token beginToken, Token token) {
    // TODO(paulberry): set up scopes properly to resolve parameters and type
    // variables.  Note that this is tricky due to the handling of initializers
    // in constructors, so the logic should be shared with BodyBuilder as much
    // as possible.
    debugEvent("FunctionExpression");

    var body = pop() as FunctionBody;
    var parameters = pop() as FormalParameterList?;
    var typeParameters = pop() as TypeParameterList?;
    push(ast.functionExpression(typeParameters, parameters, body));
  }

  @override
  void endFunctionName(Token beginToken, Token token) {
    debugEvent("FunctionName");
  }

  @override
  void endFunctionType(Token functionToken, Token? questionMark) {
    assert(optional('Function', functionToken));
    debugEvent("FunctionType");

    var parameters = pop() as FormalParameterList;
    var returnType = pop() as TypeAnnotation?;
    var typeParameters = pop() as TypeParameterList?;
    push(ast.genericFunctionType(
        returnType, functionToken, typeParameters, parameters,
        question: questionMark));
  }

  @override
  void endFunctionTypedFormalParameter(Token nameToken, Token? question) {
    debugEvent("FunctionTypedFormalParameter");

    var formalParameters = pop() as FormalParameterList;
    var returnType = pop() as TypeAnnotation?;
    var typeParameters = pop() as TypeParameterList?;

    // Create a temporary formal parameter that will be dissected later in
    // [endFormalParameter].
    push(ast.functionTypedFormalParameter2(
        identifier: ast.simpleIdentifier(
          StringToken(type: TokenType.IDENTIFIER, value: '', offset: 0),
        ),
        returnType: returnType,
        typeParameters: typeParameters,
        parameters: formalParameters,
        question: question));
  }

  @override
  void endIfControlFlow(Token token) {
    var thenElement = pop() as CollectionElement;
    var condition = pop() as ParenthesizedExpression;
    var ifToken = pop() as Token;
    pushIfControlFlowInfo(ifToken, condition, thenElement, null, null);
  }

  @override
  void endIfElseControlFlow(Token token) {
    var elseElement = pop() as CollectionElement;
    var elseToken = pop() as Token;
    var thenElement = pop() as CollectionElement;
    var condition = pop() as ParenthesizedExpression;
    var ifToken = pop() as Token;
    pushIfControlFlowInfo(
        ifToken, condition, thenElement, elseToken, elseElement);
  }

  @override
  void endIfStatement(Token ifToken, Token? elseToken) {
    assert(optional('if', ifToken));
    assert(optionalOrNull('else', elseToken));

    var elsePart = popIfNotNull(elseToken) as Statement?;
    var thenPart = pop() as Statement;
    var condition = pop() as ParenthesizedExpression;
    push(ast.ifStatement(
        ifToken,
        condition.leftParenthesis,
        condition.expression,
        condition.rightParenthesis,
        thenPart,
        elseToken,
        elsePart));
  }

  @override
  void endInitializedIdentifier(Token nameToken) {
    debugEvent("InitializedIdentifier");

    var node = pop() as AstNode?;
    VariableDeclaration variable;
    // TODO(paulberry): This seems kludgy.  It would be preferable if we
    // could respond to a "handleNoVariableInitializer" event by converting a
    // SimpleIdentifier into a VariableDeclaration, and then when this code was
    // reached, node would always be a VariableDeclaration.
    if (node is VariableDeclaration) {
      variable = node;
    } else if (node is SimpleIdentifier) {
      variable = _makeVariableDeclaration(node, null, null);
    } else {
      internalProblem(
          templateInternalProblemUnhandled.withArguments(
              "${node.runtimeType}", "identifier"),
          nameToken.charOffset,
          uri);
    }
    push(variable);
  }

  @override
  void endLabeledStatement(int labelCount) {
    debugEvent("LabeledStatement");

    var statement = pop() as Statement;
    var labels = popTypedList2<Label>(labelCount);
    push(ast.labeledStatement(labels, statement));
  }

  @override
  void endLiteralString(int interpolationCount, Token endToken) {
    debugEvent("endLiteralString");

    if (interpolationCount == 0) {
      var token = pop() as Token;
      String value = unescapeString(token.lexeme, token, this);
      push(ast.simpleStringLiteral(token, value));
    } else {
      var parts = popTypedList(1 + interpolationCount * 2)!;
      var first = parts.first as Token;
      var last = parts.last as Token;
      Quote quote = analyzeQuote(first.lexeme);
      List<InterpolationElement> elements = <InterpolationElement>[];
      elements.add(ast.interpolationString(
          first, unescapeFirstStringPart(first.lexeme, quote, first, this)));
      for (int i = 1; i < parts.length - 1; i++) {
        var part = parts[i];
        if (part is Token) {
          elements.add(ast.interpolationString(
              part, unescape(part.lexeme, quote, part, this)));
        } else if (part is InterpolationExpression) {
          elements.add(part);
        } else {
          internalProblem(
              templateInternalProblemUnhandled.withArguments(
                  "${part.runtimeType}", "string interpolation"),
              first.charOffset,
              uri);
        }
      }
      elements.add(ast.interpolationString(
          last, unescapeLastStringPart(last.lexeme, quote, last, false, this)));
      push(ast.stringInterpolation(elements));
    }
  }

  @override
  void endLiteralSymbol(Token hashToken, int tokenCount) {
    assert(optional('#', hashToken));
    debugEvent("LiteralSymbol");

    var components = popTypedList2<Token>(tokenCount);
    push(ast.symbolLiteral(hashToken, components));
  }

  @override
  void endLocalFunctionDeclaration(Token token) {
    debugEvent("LocalFunctionDeclaration");
    var body = pop() as FunctionBody;
    if (isFullAst) {
      pop(); // constructor initializers
      pop(); // separator before constructor initializers
    }
    var parameters = pop() as FormalParameterList;
    checkFieldFormalParameters(parameters);
    var name = pop() as SimpleIdentifier;
    var returnType = pop() as TypeAnnotation?;
    var typeParameters = pop() as TypeParameterList?;
    var metadata = pop(NullValue.Metadata) as List<Annotation>?;
    FunctionExpression functionExpression =
        ast.functionExpression(typeParameters, parameters, body);
    var functionDeclaration = ast.functionDeclaration(
        null, metadata, null, returnType, null, name, functionExpression);
    push(ast.functionDeclarationStatement(functionDeclaration));
  }

  @override
  void endMember() {
    debugEvent("Member");
  }

  @override
  void endNamedFunctionExpression(Token endToken) {
    debugEvent("NamedFunctionExpression");
    var body = pop() as FunctionBody;
    if (isFullAst) {
      pop(); // constructor initializers
      pop(); // separator before constructor initializers
    }
    var parameters = pop() as FormalParameterList;
    pop(); // name
    pop(); // returnType
    var typeParameters = pop() as TypeParameterList?;
    push(ast.functionExpression(typeParameters, parameters, body));
  }

  @override
  void endOptionalFormalParameters(
      int count, Token leftDelimeter, Token rightDelimeter) {
    assert((optional('[', leftDelimeter) && optional(']', rightDelimeter)) ||
        (optional('{', leftDelimeter) && optional('}', rightDelimeter)));
    debugEvent("OptionalFormalParameters");

    push(_OptionalFormalParameters(
        popTypedList2<FormalParameter>(count), leftDelimeter, rightDelimeter));
  }

  @override
  void endProgram(Token endToken) {
    debugEvent("CompilationUnit");

    var expression = pop();
    if (expression is! Expression) {
      var token = expression as Token;
      handleRecoverableError(
          Message(Code('TypeError'), problemMessage: 'Unexpect Expression'),
          token,
          endToken);
      return;
    }
    var beginToken = pop();
    if (beginToken is! Token) {
      var exp = beginToken as Expression;
      handleRecoverableError(
          Message(Code('TypeError'), problemMessage: 'Unexpect Token'),
          exp.beginToken,
          exp.endToken);
    } else {
      checkEmpty(endToken.charOffset);

      var program = ast.program(beginToken, endToken, expression as Expression);
      push(program);
    }
  }

  @override
  void endReturnStatement(
      bool hasExpression, Token returnKeyword, Token semicolon) {
    assert(optional('return', returnKeyword));
    assert(optional(';', semicolon));
    debugEvent("ReturnStatement");

    var expression = hasExpression ? pop() as Expression : null;
    push(ast.returnStatement(returnKeyword, expression, semicolon));
  }

  @override
  void endSwitchBlock(int caseCount, Token leftBracket, Token rightBracket) {
    assert(optional('{', leftBracket));
    assert(optional('}', rightBracket));
    debugEvent("SwitchBlock");

    var membersList = popTypedList2<List<SwitchMember>>(caseCount);
    List<SwitchMember> members =
        membersList.expand((members) => members).toList();

    Set<String> labels = <String>{};
    for (SwitchMember member in members) {
      for (Label label in member.labels) {
        if (!labels.add(label.label.name)) {
          handleRecoverableError(
              templateDuplicateLabelInSwitchStatement
                  .withArguments(label.label.name),
              label.beginToken,
              label.beginToken);
        }
      }
    }

    push(leftBracket);
    push(members);
    push(rightBracket);
  }

  @override
  void endSwitchCase(
      int labelCount,
      int expressionCount,
      Token? defaultKeyword,
      Token? colonAfterDefault,
      int statementCount,
      Token firstToken,
      Token endToken) {
    assert(optionalOrNull('default', defaultKeyword));
    assert(defaultKeyword == null
        ? colonAfterDefault == null
        : optional(':', colonAfterDefault!));
    debugEvent("SwitchCase");

    var statements = popTypedList2<Statement>(statementCount);
    List<SwitchMember?> members;

    if (labelCount == 0 && defaultKeyword == null) {
      // Common situation: case with no default and no labels.
      members = popTypedList2<SwitchMember>(expressionCount);
    } else {
      // Labels and case statements may be intertwined
      if (defaultKeyword != null) {
        SwitchDefault member = ast.switchDefault(
            <Label>[], defaultKeyword, colonAfterDefault!, <Statement>[]);
        while (peek() is Label) {
          member.labels.insert(0, pop() as Label);
          --labelCount;
        }
        members = List<SwitchMember?>.filled(expressionCount + 1, null);
        members[expressionCount] = member;
      } else {
        members = List<SwitchMember?>.filled(expressionCount, null);
      }
      for (int index = expressionCount - 1; index >= 0; --index) {
        var member = pop() as SwitchMember;
        while (peek() is Label) {
          member.labels.insert(0, pop() as Label);
          --labelCount;
        }
        members[index] = member;
      }
      assert(labelCount == 0);
    }
    var members2 = members.where((element) => element != null).toList();
    if (members2.isNotEmpty) {
      members2.last!.statements.addAll(statements);
    }
    push(members2);
  }

  @override
  void endSwitchStatement(Token switchKeyword, Token endToken) {
    assert(optional('switch', switchKeyword));
    debugEvent("SwitchStatement");

    var rightBracket = pop() as Token;
    var members = pop() as List<SwitchMember>;
    var leftBracket = pop() as Token;
    var expression = pop() as ParenthesizedExpression;
    push(ast.switchStatement(
        switchKeyword,
        expression.leftParenthesis,
        expression.expression,
        expression.rightParenthesis,
        leftBracket,
        members,
        rightBracket));
  }

  @override
  void endThenStatement(Token token) {
    debugEvent("endThenStatement");
  }

  @override
  void endTopLevelDeclaration(Token token) {
    debugEvent("TopLevelDeclaration");
  }

  @override
  void endTopLevelFields(
      Token? varFinalOrConst, int count, Token beginToken, Token semicolon) {
    assert(optional(';', semicolon));
    debugEvent("TopLevelFields");

    var variables = popTypedList2<VariableDeclaration>(count);
    var type = pop() as TypeAnnotation?;
    var variableList = ast.variableDeclarationList2(
      keyword: varFinalOrConst,
      type: type,
      variables: variables,
    );
    var metadata = pop() as List<Annotation>?;
    var comment = _findComment(metadata, beginToken);
    declarations.add(ast.topLevelVariableDeclaration(
        comment, metadata, variableList, semicolon));
  }

  @override
  void endTopLevelMethod(Token beginToken, Token endToken) {
    debugEvent("TopLevelMethod");

    var body = pop() as FunctionBody;
    var parameters = pop() as FormalParameterList?;
    // var typeParameters = pop() as TypeParameterList?;
    var name = pop() as SimpleIdentifier;
    var returnType = pop() as TypeAnnotation?;
    var modifiers = pop() as _Modifiers?;
    // var externalKeyword = modifiers?.externalKeyword;
    // var metadata = pop() as List<Annotation>?;
    // var comment = _findComment(metadata, beginToken);
    declarations.add(ast.functionDeclaration(null, null, null, returnType, null,
        name, ast.functionExpression(null, parameters, body)));
  }

  @override
  void endTypeArguments(int count, Token leftBracket, Token rightBracket) {
    assert(optional('<', leftBracket));
    assert(optional('>', rightBracket));
    debugEvent("TypeArguments");

    var arguments = popTypedList2<TypeAnnotation>(count);
    push(ast.typeArgumentList(leftBracket, arguments, rightBracket));
  }

  @override
  void endTypeList(int count) {
    debugEvent("TypeList");
    push(popTypedList<NamedType>(count) ?? NullValue.TypeList);
  }

  @override
  void endVariableInitializer(Token assignmentOperator) {
    assert(optionalOrNull('=', assignmentOperator));
    debugEvent("VariableInitializer");

    var initializer = pop() as Expression;
    var identifier = pop() as SimpleIdentifier;
    // TODO(ahe): Don't push initializers, instead install them.
    push(_makeVariableDeclaration(identifier, assignmentOperator, initializer));
  }

  @override
  void endVariablesDeclaration(int count, Token? semicolon) {
    assert(optionalOrNull(';', semicolon));
    debugEvent("VariablesDeclaration");

    var variables = popTypedList2<VariableDeclaration>(count);
    var modifiers = pop(NullValue.Modifiers) as _Modifiers?;
    var type = pop() as TypeAnnotation?;
    var keyword = modifiers?.finalConstOrVarKeyword;
    var metadata = pop() as List<Annotation>?;
    var comment = _findComment(metadata, variables[0].beginToken);
    // var comment = _findComment(metadata,
    //     variables[0].beginToken ?? type?.beginToken ?? modifiers.beginToken);
    push(ast.variableDeclarationStatement(
        ast.variableDeclarationList2(
          comment: comment,
          metadata: metadata,
          keyword: keyword,
          type: type,
          variables: variables,
        ),
        semicolon ?? SimpleToken(type: TokenType.SEMICOLON)));
  }

  @override
  void endWhileStatement(Token whileKeyword, Token endToken) {
    assert(optional('while', whileKeyword));
    debugEvent("WhileStatement");

    var body = pop() as Statement;
    var condition = pop() as ParenthesizedExpression;
    push(ast.whileStatement(whileKeyword, condition.leftParenthesis,
        condition.expression, condition.rightParenthesis, body));
  }

  @override
  void endWhileStatementBody(Token token) {
    debugEvent("endWhileStatementBody");
  }

  @override
  void handleAssignmentExpression(Token token) {
    assert(token.type.isAssignmentOperator);
    debugEvent("AssignmentExpression");

    var rhs = pop() as Expression;
    var lhs = pop() as Expression;
    if (!lhs.isAssignable) {
      // TODO(danrubel): Update the BodyBuilder to report this error.
      handleRecoverableError(
          messageMissingAssignableSelector, lhs.beginToken, lhs.endToken);
    }
    push(ast.assignmentExpression(lhs, token, rhs));
  }

  @override
  void handleBreakStatement(
      bool hasTarget, Token breakKeyword, Token semicolon) {
    assert(optional('break', breakKeyword));
    assert(optional(';', semicolon));
    debugEvent("BreakStatement");

    var label = hasTarget ? pop() as SimpleIdentifier : null;
    push(ast.breakStatement(breakKeyword, label, semicolon));
  }

  @override
  void handleCaseMatch(Token caseKeyword, Token colon) {
    assert(optional('case', caseKeyword));
    assert(optional(':', colon));
    debugEvent("CaseMatch");

    var expression = pop() as Expression;
    push(ast.switchCase(
        <Label>[], caseKeyword, expression, colon, <Statement>[]));
  }

  @override
  void handleCommentReference(
    Token? newKeyword,
    Token? firstToken,
    Token? firstPeriod,
    Token? secondToken,
    Token? secondPeriod,
    Token thirdToken,
  ) {
    var identifier = ast.simpleIdentifier(thirdToken);
    if (firstToken != null) {
      var target = ast.prefixedIdentifier(ast.simpleIdentifier(firstToken),
          firstPeriod!, ast.simpleIdentifier(secondToken!));
      var expression = ast.propertyAccess(target, secondPeriod!, identifier);
      push(ast.commentReference(newKeyword, expression));
    } else if (secondToken != null) {
      var expression = ast.prefixedIdentifier(
          ast.simpleIdentifier(secondToken), secondPeriod!, identifier);
      push(ast.commentReference(newKeyword, expression));
    } else {
      push(ast.commentReference(newKeyword, identifier));
    }
  }

  @override
  void handleCommentReferenceText(String referenceSource, int referenceOffset) {
    push(referenceSource);
    push(referenceOffset);
  }

  @override
  void handleContinueStatement(
      bool hasTarget, Token continueKeyword, Token semicolon) {
    assert(optional('continue', continueKeyword));
    assert(optional(';', semicolon));
    debugEvent("ContinueStatement");

    var label = hasTarget ? pop() as SimpleIdentifier : null;
    push(ast.continueStatement(continueKeyword, label, semicolon));
  }

  @override
  void handleDottedName(int count, Token firstIdentifier) {
    assert(firstIdentifier.isIdentifier);
    debugEvent("DottedName");

    var components = popTypedList2<SimpleIdentifier>(count);
    push(ast.dottedName(components));
  }

  @override
  void handleElseControlFlow(Token elseToken) {
    push(elseToken);
  }

  @override
  void handleEmptyFunctionBody(Token semicolon) {
    assert(optional(';', semicolon));
    debugEvent("EmptyFunctionBody");

    // TODO(scheglov) Change the parser to not produce these modifiers.
    pop(); // star
    pop(); // async
    push(ast.emptyFunctionBody(semicolon));
  }

  @override
  void handleEmptyStatement(Token semicolon) {
    assert(optional(';', semicolon));
    debugEvent("EmptyStatement");

    push(ast.emptyStatement(semicolon));
  }

  @override
  void handleErrorToken(ErrorToken token) {
    translateErrorToken(token, errorReporter.reportScannerError);
  }

  @override
  void handleExpressionFunctionBody(Token arrowToken, Token? semicolon) {
    assert(optional('=>', arrowToken) || optional('=', arrowToken));
    assert(optionalOrNull(';', semicolon));
    debugEvent("ExpressionFunctionBody");

    var expression = pop() as Expression;
    var star = pop() as Token?;
    var asyncKeyword = pop() as Token?;
    if (parseFunctionBodies) {
      push(ast.expressionFunctionBody2(
        keyword: asyncKeyword,
        star: star,
        functionDefinition: arrowToken,
        expression: expression,
        semicolon: semicolon,
      ));
    } else {
      push(ast.emptyFunctionBody(semicolon!));
    }
  }

  @override
  void handleExpressionStatement(Token semicolon) {
    assert(optional(';', semicolon));
    debugEvent("ExpressionStatement");
    var expression = pop() as Expression;
    if (expression is SimpleIdentifier &&
        expression.token.isKeyword &&
        (expression.token as KeywordToken).keyword.isBuiltInOrPseudo == false) {
      // This error is also reported by the body builder.
      handleRecoverableError(
          messageExpectedStatement, expression.beginToken, expression.endToken);
    }
    if (expression is AssignmentExpression) {
      if (!expression.leftHandSide.isAssignable) {
        // This error is also reported by the body builder.
        handleRecoverableError(
            messageIllegalAssignmentToNonAssignable,
            expression.leftHandSide.beginToken,
            expression.leftHandSide.endToken);
      }
    }
    push(ast.expressionStatement(expression, semicolon));
  }

  @override
  void handleForInitializerEmptyStatement(Token token) {
    debugEvent("ForInitializerEmptyStatement");
    push(NullValue.Expression);
  }

  @override
  void handleForInitializerExpressionStatement(Token token, bool forIn) {
    debugEvent("ForInitializerExpressionStatement");
  }

  @override
  void handleForInitializerLocalVariableDeclaration(Token token, bool forIn) {
    debugEvent("ForInitializerLocalVariableDeclaration");
  }

  @override
  void handleForInLoopParts(Token? awaitToken, Token forToken,
      Token leftParenthesis, Token inKeyword) {
    assert(optionalOrNull('await', awaitToken));
    assert(optional('for', forToken));
    assert(optional('(', leftParenthesis));
    assert(optional('in', inKeyword) || optional(':', inKeyword));

    var iterator = pop() as Expression;
    var variableOrDeclaration = pop()!;

    ForEachParts forLoopParts;
    if (variableOrDeclaration is VariableDeclarationStatement) {
      VariableDeclarationList variableList = variableOrDeclaration.variables;
      forLoopParts = ast.forEachPartsWithDeclaration(
        loopVariable: ast.declaredIdentifier(
            variableList.documentationComment,
            variableList.metadata,
            variableList.keyword,
            variableList.type,
            variableList.variables.first.name),
        inKeyword: inKeyword,
        iterable: iterator,
      );
    } else {
      if (variableOrDeclaration is! SimpleIdentifier) {
        // Parser has already reported the error.
        if (!leftParenthesis.next!.isIdentifier) {
          parser.rewriter.insertSyntheticIdentifier(leftParenthesis);
        }
        variableOrDeclaration = ast.simpleIdentifier(leftParenthesis.next!);
      }
      forLoopParts = ast.forEachPartsWithIdentifier(
        identifier: variableOrDeclaration,
        inKeyword: inKeyword,
        iterable: iterator,
      );
    }

    push(awaitToken ?? NullValue.AwaitToken);
    push(forToken);
    push(leftParenthesis);
    push(forLoopParts);
  }

  @override
  void handleForLoopParts(Token forKeyword, Token leftParen,
      Token leftSeparator, int updateExpressionCount) {
    assert(optional('for', forKeyword));
    assert(optional('(', leftParen));
    assert(optional(';', leftSeparator));
    assert(updateExpressionCount >= 0);

    var updates = popTypedList2<Expression>(updateExpressionCount);
    var conditionStatement = pop() as Statement;
    var initializerPart = pop();

    Expression? condition;
    Token rightSeparator;
    if (conditionStatement is ExpressionStatement) {
      condition = conditionStatement.expression;
      rightSeparator = conditionStatement.semicolon!;
    } else {
      rightSeparator = (conditionStatement as EmptyStatement).semicolon;
    }

    ForParts forLoopParts;
    if (initializerPart is VariableDeclarationStatement) {
      forLoopParts = ast.forPartsWithDeclarations(
        variables: initializerPart.variables,
        leftSeparator: leftSeparator,
        condition: condition,
        rightSeparator: rightSeparator,
        updaters: updates,
      );
    } else {
      forLoopParts = ast.forPartsWithExpression(
        initialization: initializerPart as Expression?,
        leftSeparator: leftSeparator,
        condition: condition,
        rightSeparator: rightSeparator,
        updaters: updates,
      );
    }

    push(forKeyword);
    push(leftParen);
    push(forLoopParts);
  }

  @override
  void handleFormalParameterWithoutValue(Token token) {
    debugEvent("FormalParameterWithoutValue");

    push(NullValue.ParameterDefaultValue);
  }

  @override
  void handleIdentifier(Token token, IdentifierContext context) {
    assert(token.isKeywordOrIdentifier);
    debugEvent("handleIdentifier");

    if (context.inSymbol) {
      push(token);
      return;
    }

    SimpleIdentifier identifier =
        ast.simpleIdentifier(token, isDeclaration: context.inDeclaration);
    if (context.inLibraryOrPartOfDeclaration) {
      if (!context.isContinuation) {
        push([identifier]);
      } else {
        push(identifier);
      }
    } else {
      push(identifier);
    }
  }

  @override
  void handleIdentifierList(int count) {
    debugEvent("IdentifierList");

    push(popTypedList<SimpleIdentifier>(count) ?? NullValue.IdentifierList);
  }

  @override
  void handleIndexedExpression(
      Token? question, Token leftBracket, Token rightBracket) {
    assert(optional('[', leftBracket));
    assert(optional(']', rightBracket));
    debugEvent("IndexedExpression");

    var index = pop() as Expression;
    var target = pop() as Expression?;
    if (target == null) {
      var receiver = pop() as CascadeExpression;
      var token = peek() as Token;
      push(receiver);
      IndexExpression expression = ast.indexExpressionForCascade2(
          period: token,
          question: question,
          leftBracket: leftBracket,
          index: index,
          rightBracket: rightBracket);
      assert(expression.isCascaded);
      push(expression);
    } else {
      push(ast.indexExpressionForTarget2(
          target: target,
          question: question,
          leftBracket: leftBracket,
          index: index,
          rightBracket: rightBracket));
    }
  }

  @override
  void handleInterpolationExpression(Token leftBracket, Token? rightBracket) {
    var expression = pop() as Expression;
    push(ast.interpolationExpression(leftBracket, expression, rightBracket));
  }

  @override
  void handleInvalidExpression(Token token) {
    debugEvent("InvalidExpression");
  }

  @override
  void handleInvalidFunctionBody(Token leftBracket) {
    assert(optional('{', leftBracket));
    assert(optional('}', leftBracket.endGroup!));
    debugEvent("InvalidFunctionBody");
    Block block = ast.block(leftBracket, [], leftBracket.endGroup!);
    var star = pop() as Token?;
    var asyncKeyword = pop() as Token?;
    push(ast.blockFunctionBody(asyncKeyword, star, block));
  }

  @override
  void handleInvalidMember(Token endToken) {
    debugEvent("InvalidMember");
    pop(); // metadata star
  }

  @override
  void handleInvalidOperatorName(Token operatorKeyword, Token token) {
    assert(optional('operator', operatorKeyword));
    debugEvent("InvalidOperatorName");

    push(_OperatorName(
        operatorKeyword, ast.simpleIdentifier(token, isDeclaration: true)));
  }

  @override
  void handleInvalidTopLevelBlock(Token token) {
    // TODO(danrubel): Consider improved recovery by adding this block
    // as part of a synthetic top level function.
    pop(); // block
  }

  @override
  void handleInvalidTopLevelDeclaration(Token endToken) {
    debugEvent("InvalidTopLevelDeclaration");

    // pop(); // metadata star
    // TODO(danrubel): consider creating a AST node
    // representing the invalid declaration to better support code completion,
    // quick fixes, etc, rather than discarding the metadata and token
  }

  @override
  void handleInvalidTypeArguments(Token token) {
    var invalidTypeArgs = pop() as TypeArgumentList;
    var node = pop();
  }

  @override
  void handleLabel(Token colon) {
    assert(optionalOrNull(':', colon));
    debugEvent("Label");

    var name = pop() as SimpleIdentifier;
    push(ast.label(name, colon));
  }

  @override
  void handleLiteralBool(Token token) {
    bool value = identical(token.toString(), "true");
    assert(value || identical(token.toString(), "false"));
    debugEvent("LiteralBool");

    push(ast.booleanLiteral(token, value));
  }

  @override
  void handleLiteralDouble(Token token) {
    assert(token.type == TokenType.DOUBLE);
    debugEvent("LiteralDouble");

    push(ast.doubleLiteral(token, double.parse(token.lexeme)));
  }

  @override
  void handleLiteralInt(Token token) {
    assert(identical(token.kind, INT_TOKEN) ||
        identical(token.kind, HEXADECIMAL_TOKEN));
    debugEvent("LiteralInt");

    push(ast.integerLiteral(token, int.tryParse(token.lexeme)));
  }

  @override
  void handleLiteralList(
      int count, Token leftBracket, Token? constKeyword, Token rightBracket) {
    assert(optional('[', leftBracket));
    assert(optionalOrNull('const', constKeyword));
    assert(optional(']', rightBracket));
    debugEvent("LiteralList");

    var elements = popTypedList<Expression>(count) ?? const [];
    var typeArguments = pop() as TypeArgumentList?;

    List<Expression> expressions = <Expression>[];
    for (var elem in elements) {
      expressions.add(elem);
    }

    push(ast.listLiteral(
        constKeyword, typeArguments, leftBracket, expressions, rightBracket));
  }

  @override
  void handleLiteralMapEntry(Token colon, Token endToken) {
    assert(optional(':', colon));
    debugEvent("LiteralMapEntry");

    var value = pop() as Expression;
    var key = pop() as Expression;
    push(ast.mapLiteralEntry(key, colon, value));
  }

  @override
  void handleLiteralNull(Token token) {
    assert(optional('null', token));
    debugEvent("LiteralNull");

    push(ast.nullLiteral(token));
  }

  @override
  void handleLiteralSetOrMap(
    int count,
    Token leftBrace,
    Token? constKeyword,
    Token rightBrace,
    // TODO(danrubel): hasSetEntry parameter exists for replicating existing
    // behavior and will be removed once unified collection has been enabled
    bool hasSetEntry,
  ) {
    var elements = popTypedList(count);
    var typeArguments = pop() as TypeArgumentList?;

    // Replicate existing behavior that has been removed from the parser.
    // This will be removed once control flow collections
    // and spread collections are enabled by default.

    // Determine if this is a set or map based on type args and content
    final typeArgCount = typeArguments?.arguments.length;
    bool? isSet = typeArgCount == 1
        ? true
        : typeArgCount != null
            ? false
            : null;
    isSet ??= hasSetEntry;

    // Build the set or map
    if (isSet) {
      final setEntries = <Expression>[];
      if (elements != null) {
        for (var elem in elements) {
          if (elem is MapLiteralEntry) {
            setEntries.add(elem.key);
            handleRecoverableError(
                templateUnexpectedToken.withArguments(elem.separator),
                elem.separator,
                elem.separator);
          } else if (elem is Expression) {
            setEntries.add(elem);
          }
        }
      }
      push(ast.setOrMapLiteral(
        constKeyword: constKeyword,
        typeArguments: typeArguments,
        leftBracket: leftBrace,
        elements: setEntries,
        rightBracket: rightBrace,
      ));
    } else {
      final mapEntries = <MapLiteralEntry>[];
      if (elements != null) {
        for (var elem in elements) {
          if (elem is MapLiteralEntry) {
            mapEntries.add(elem);
          } else if (elem is Expression) {
            Token next = elem.endToken.next!;
            int offset = next.offset;
            handleRecoverableError(
                templateExpectedButGot.withArguments(':'), next, next);
            handleRecoverableError(
                templateExpectedIdentifier.withArguments(next), next, next);
            Token separator =
                SimpleToken(type: TokenType.COLON, offset: offset);
            Expression value = ast.simpleIdentifier(StringToken(
                type: TokenType.IDENTIFIER, value: '', offset: offset));
            mapEntries.add(ast.mapLiteralEntry(elem, separator, value));
          }
        }
      }
      push(ast.setOrMapLiteral(
        constKeyword: constKeyword,
        typeArguments: typeArguments,
        leftBracket: leftBrace,
        elements: mapEntries,
        rightBracket: rightBrace,
      ));
    }
  }

  @override
  void handleNamedArgument(Token colon) {
    assert(optional(':', colon));
    debugEvent("NamedArgument");

    var expression = pop() as Expression;
    var name = pop() as SimpleIdentifier;
    push(ast.namedExpression(ast.label(name, colon), expression));
  }

  @override
  void handleNoInitializers() {
    debugEvent("NoInitializers");

    if (!isFullAst) return;
    push(NullValue.ConstructorInitializerSeparator);
    push(NullValue.ConstructorInitializers);
  }

  @override
  void handleNoVariableInitializer(Token token) {
    debugEvent("NoVariableInitializer");
  }

  @override
  void handleOperatorName(Token operatorKeyword, Token token) {
    assert(optional('operator', operatorKeyword));
    assert(token.type.isUserDefinableOperator);
    debugEvent("OperatorName");

    push(_OperatorName(
        operatorKeyword, ast.simpleIdentifier(token, isDeclaration: true)));
  }

  @override
  void handleParenthesizedCondition(Token leftParenthesis) {
    // TODO(danrubel): Implement rather than forwarding.
    handleParenthesizedExpression(leftParenthesis);
  }

  @override
  void handleParenthesizedExpression(Token leftParenthesis) {
    assert(optional('(', leftParenthesis));
    debugEvent("ParenthesizedExpression");

    var expression = pop() as Expression;
    push(ast.parenthesizedExpression(
        leftParenthesis, expression, leftParenthesis.endGroup!));
  }

  @override
  void handleQualified(Token period) {
    assert(optional('.', period));

    var identifier = pop() as SimpleIdentifier;
    var prefix = pop();
    if (prefix is List) {
      // We're just accumulating components into a list.
      prefix.add(identifier);
      push(prefix);
    } else if (prefix is SimpleIdentifier) {
      // TODO(paulberry): resolve [identifier].  Note that BodyBuilder handles
      // this situation using SendAccessGenerator.
      push(ast.prefixedIdentifier(prefix, period, identifier));
    } else {
      // TODO(paulberry): implement.
      logEvent('Qualified with >1 dot');
    }
  }

  @override
  void handleRecoverableError(
      Message message, Token startToken, Token endToken) {
    /// TODO(danrubel): Ignore this error until we deprecate `native` support.
    if (message == messageNativeClauseShouldBeAnnotation && allowNativeClause) {
      return;
    }
    debugEvent("Error: ${message.problemMessage}");
    if (message.code.analyzerCodes == null && startToken is ErrorToken) {
    } else {
      int offset = startToken.offset;
      int length = endToken.end - offset;
      addProblem(message, offset, length);
    }
  }

  @override
  void handleSend(Token beginToken, Token endToken) {
    debugEvent("Send");

    var arguments = pop() as MethodInvocationImpl?;
    var typeArguments = pop() as TypeArgumentListImpl?;
    if (arguments != null) {
      doInvocation(typeArguments, arguments);
    } else {
      doPropertyGet();
    }
  }

  @override
  void handleStringJuxtaposition(Token startToken, int literalCount) {
    debugEvent("StringJuxtaposition");

    var strings = popTypedList2<StringLiteral>(literalCount);
    push(ast.adjacentStrings(strings));
  }

  @override
  void handleStringPart(Token literalString) {
    assert(identical(literalString.kind, STRING_TOKEN));
    debugEvent("StringPart");

    push(literalString);
  }

  @override
  void handleSymbolVoid(Token voidKeyword) {
    assert(optional('void', voidKeyword));
    debugEvent("SymbolVoid");

    push(voidKeyword);
  }

  @override
  void handleType(Token beginToken, Token? questionMark) {
    debugEvent("Type");
    var arguments = pop() as TypeArgumentList?;
    var name = pop() as Identifier;
    push(
      ast.namedType(
        name: name,
        typeArguments: arguments,
        question: questionMark,
      ),
    );
  }

  @override
  void handleTypeArgumentApplication(Token openAngleBracket) {
    var typeArguments = pop() as TypeArgumentList;
    var receiver = pop() as Expression;
    push(ast.functionReference(
        function: receiver, typeArguments: typeArguments));
  }

  @override
  void handleUnaryPostfixAssignmentExpression(Token operator) {
    assert(operator.type.isUnaryPostfixOperator);
    debugEvent("UnaryPostfixAssignmentExpression");

    var expression = pop() as Expression;
    if (!expression.isAssignable) {
      // This error is also reported by the body builder.
      handleRecoverableError(
          messageIllegalAssignmentToNonAssignable, operator, operator);
    }
    push(ast.postfixExpression(expression, operator));
  }

  @override
  void handleUnaryPrefixAssignmentExpression(Token operator) {
    assert(operator.type.isUnaryPrefixOperator);
    debugEvent("UnaryPrefixAssignmentExpression");

    var expression = pop() as Expression;
    if (!expression.isAssignable) {
      // This error is also reported by the body builder.
      handleRecoverableError(messageMissingAssignableSelector,
          expression.endToken, expression.endToken);
    }
    push(ast.prefixExpression(operator, expression));
  }

  @override
  void handleUnaryPrefixExpression(Token operator) {
    assert(operator.type.isUnaryPrefixOperator);
    debugEvent("UnaryPrefixExpression");

    push(ast.prefixExpression(operator, pop() as Expression));
  }

  @override
  void handleValuedFormalParameter(Token equals, Token token) {
    assert(optional('=', equals) || optional(':', equals));
    debugEvent("ValuedFormalParameter");

    var value = pop() as Expression;
    push(_ParameterDefaultValue(equals, value));
  }

  @override
  Never internalProblem(Message message, int charOffset, [Uri? uri]) {
    throw UnsupportedError(message.problemMessage);
  }

  /// Return `true` if [token] is either `null` or is the symbol or keyword
  /// [value].
  bool optionalOrNull(String value, Token? token) {
    return token == null || identical(value, token.toString());
  }

  List<CollectionElement> popCollectionElements(int count) {
    // TODO(scheglov) Not efficient.
    final elements = <CollectionElement>[];
    for (int index = count - 1; index >= 0; --index) {
      var element = pop();
      elements.add(element as CollectionElement);
    }
    return elements.reversed.toList();
  }

  List? popList(int n, List list) {
    if (n == 0) return null;
    return stack.popList(n, list, null);
  }

  List<T>? popTypedList<T extends Object>(int count) {
    if (count == 0) return null;
    assert(stack.length >= count);

    final tailList = List<T?>.filled(count, null, growable: true);
    stack.popList(count, tailList, null);
    return tailList.where((element) => element != null).toList().cast<T>();
  }

  // List<T?>? popTypedList<T>(int count, [List<T>? list]) {
  //   if (count == 0) return null;
  //   assert(stack.length >= count);
  //
  //   final tailList = list ?? List<T?>.filled(count, null, growable: true);
  //   stack.popList(count, tailList, null);
  //   return tailList;
  // }

  /// TODO(scheglov) This is probably not optimal.
  List<T> popTypedList2<T>(int count) {
    var result = <T>[];
    for (var i = 0; i < count; i++) {
      var element = stack.pop(null) as T;
      result.add(element);
    }
    return result.reversed.toList();
  }

  void pushForControlFlowInfo(Token forToken, Token leftParenthesis,
      ForLoopParts forLoopParts, Object entry) {
    if (entry == _invalidCollectionElement) {
      push(_invalidCollectionElement);
    } else {
      push(ast.forElement(
        forKeyword: forToken,
        leftParenthesis: leftParenthesis,
        forLoopParts: forLoopParts,
        rightParenthesis: leftParenthesis.endGroup!,
        body: entry as CollectionElement,
      ));
    }
  }

  void pushIfControlFlowInfo(
      Token ifToken,
      ParenthesizedExpression condition,
      CollectionElement thenElement,
      Token? elseToken,
      CollectionElement? elseElement) {
    if (thenElement == _invalidCollectionElement ||
        elseElement == _invalidCollectionElement) {
      push(_invalidCollectionElement);
    } else {
      push(ast.ifElement(
        ifKeyword: ifToken,
        leftParenthesis: condition.leftParenthesis,
        condition: condition.expression,
        rightParenthesis: condition.rightParenthesis,
        thenElement: thenElement,
        elseKeyword: elseToken,
        elseElement: elseElement,
      ));
    }
  }

  Comment? _findComment(List<Annotation>? metadata, Token tokenAfterMetadata) {
    // Find the dartdoc tokens
    var dartdoc = parser.findDartDoc(tokenAfterMetadata);
    if (dartdoc == null) {
      if (metadata == null) {
        return null;
      }
      int index = metadata.length;
      while (true) {
        if (index == 0) {
          return null;
        }
        --index;
        dartdoc = parser.findDartDoc(metadata[index].beginToken);
        if (dartdoc != null) {
          break;
        }
      }
    }

    List<Token> tokens = <Token>[dartdoc];
    if (dartdoc.lexeme.startsWith('///')) {
      dartdoc = dartdoc.next;
      while (dartdoc != null) {
        if (dartdoc.lexeme.startsWith('///')) {
          tokens.add(dartdoc);
        }
        dartdoc = dartdoc.next;
      }
    }
    return ast.documentationComment(tokens);
  }

  VariableDeclaration _makeVariableDeclaration(
      SimpleIdentifier name, Token? equals, Expression? initializer) {
    return ast.variableDeclaration(name, equals, initializer);
  }

  SimpleIdentifier _tmpSimpleIdentifier() {
    return ast.simpleIdentifier(
      StringToken(type: TokenType.STRING, value: '__tmp', offset: -1),
    );
  }

  ParameterKind _toAnalyzerParameterKind(
      FormalParameterKind type, Token? requiredKeyword) {
    if (type == FormalParameterKind.optionalPositional) {
      return ParameterKind.POSITIONAL;
    } else if (type == FormalParameterKind.optionalNamed) {
      if (requiredKeyword != null) {
        return ParameterKind.NAMED_REQUIRED;
      }
      return ParameterKind.NAMED;
    } else {
      return ParameterKind.REQUIRED;
    }
  }
}

/// When [enableSpreadCollections] and/or [enableControlFlowCollections]
/// are false, this class is pushed on the stack when a disabled
/// [CollectionElement] has been parsed.
class _InvalidCollectionElement implements CollectionElement {
  // TODO(danrubel): Remove this once control flow and spread collections
  // have been enabled by default.

  const _InvalidCollectionElement._();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Data structure placed on the stack to represent a non-empty sequence
/// of modifiers.
class _Modifiers {
  Token? finalConstOrVarKeyword;

  /// Return the token that is lexically first.
  Token? get beginToken {
    Token? firstToken;
    for (Token? token in [
      finalConstOrVarKeyword,
    ]) {
      if (firstToken == null) {
        firstToken = token;
      } else if (token != null) {
        if (token.offset < firstToken.offset) {
          firstToken = token;
        }
      }
    }
    return firstToken;
  }

  /// Return the `const` keyword or `null`.
  Token? get constKeyword {
    return identical('const', finalConstOrVarKeyword?.lexeme)
        ? finalConstOrVarKeyword
        : null;
  }
}

/// Data structure placed on the stack to represent the keyword "operator"
/// followed by a token.
class _OperatorName {
  final Token operatorKeyword;
  final SimpleIdentifier name;

  _OperatorName(this.operatorKeyword, this.name);
}

/// Data structure placed on the stack as a container for optional parameters.
class _OptionalFormalParameters {
  final List<FormalParameter>? parameters;
  final Token leftDelimiter;
  final Token rightDelimiter;

  _OptionalFormalParameters(
      this.parameters, this.leftDelimiter, this.rightDelimiter);
}

/// Data structure placed on the stack to represent the default parameter
/// value with the separator token.
class _ParameterDefaultValue {
  final Token separator;
  final Expression value;

  _ParameterDefaultValue(this.separator, this.value);
}
