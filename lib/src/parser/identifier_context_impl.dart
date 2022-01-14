// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:dartfx/src/lexer/tokens/token_constants.dart';

import '../messages/codes.dart' as codes;

import 'identifier_context.dart';

import 'parser.dart' show Parser;

import 'type_info.dart';
import 'util.dart' show isOneOf, isOneOfOrEof, optional;

/// See [IdentifierContext.classOrMixinOrExtensionDeclaration].
class ClassOrMixinOrExtensionIdentifierContext extends IdentifierContext {
  const ClassOrMixinOrExtensionIdentifierContext()
      : super('classOrMixinDeclaration',
            inDeclaration: true, isBuiltInIdentifierAllowed: false);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.type.isPseudo) {
      return identifier;
    }

    // Recovery
    const List<String> afterIdentifier = const [
      '<',
      '{',
      'extends',
      'with',
      'implements',
      'on',
      '=',
    ];
    if (identifier.isEof ||
        (looksLikeStartOfNextTopLevelDeclaration(identifier) &&
            (identifier.next == null ||
                !isOneOfOrEof(identifier.next!, afterIdentifier))) ||
        (isOneOfOrEof(identifier, afterIdentifier) &&
            (identifier.next == null ||
                !isOneOfOrEof(identifier.next!, afterIdentifier)))) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else if (identifier.type.isBuiltIn) {
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateBuiltInIdentifierInDeclaration);
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.combinator].
class CombinatorIdentifierContext extends IdentifierContext {
  const CombinatorIdentifierContext() : super('combinator');

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    const List<String> followingValues = const [
      ';',
      ',',
      'if',
      'as',
      'show',
      'hide'
    ];

    if (identifier.isIdentifier) {
      if (!looksLikeStartOfNextTopLevelDeclaration(identifier) ||
          isOneOfOrEof(identifier.next!, followingValues)) {
        return identifier;
      }
      // Although this is a valid identifier name, the import declaration
      // is invalid and this looks like the start of the next declaration.
      // In this situation, fall through to insert a synthetic identifier.
    }

    // Recovery
    if (isOneOfOrEof(identifier, followingValues) ||
        looksLikeStartOfNextTopLevelDeclaration(identifier)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.constructorReference]
/// and [IdentifierContext.constructorReferenceContinuation]
/// and [IdentifierContext.constructorReferenceContinuationAfterTypeArguments].
class ConstructorReferenceIdentifierContext extends IdentifierContext {
  const ConstructorReferenceIdentifierContext()
      : super('constructorReference', isScopeReference: true);

  const ConstructorReferenceIdentifierContext.continuation()
      : super('constructorReferenceContinuation', isContinuation: true);

  const ConstructorReferenceIdentifierContext.continuationAfterTypeArguments()
      : super('constructorReferenceContinuationAfterTypeArguments',
            isContinuation: true);

  @override
  bool get allowsNewAsIdentifier => isContinuation;

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (!identifier.isKeywordOrIdentifier) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      // Use the keyword as the identifier.
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifierButGotKeyword);
    }
    return identifier;
  }
}

/// See [IdentifierContext.dottedName].
class DottedNameIdentifierContext extends IdentifierContext {
  const DottedNameIdentifierContext() : super('dottedName');

  const DottedNameIdentifierContext.continuation()
      : super('dottedNameContinuation', isContinuation: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    const List<String> followingValues = const ['.', '==', ')'];

    // Recovery
    if (looksLikeStartOfNextTopLevelDeclaration(identifier) ||
        isOneOfOrEof(identifier, followingValues)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.expression].
class ExpressionIdentifierContext extends IdentifierContext {
  const ExpressionIdentifierContext()
      : super('expression', isScopeReference: true);

  const ExpressionIdentifierContext.continuation()
      : super('expressionContinuation', isContinuation: true);

  @override
  bool get allowsNewAsIdentifier => isContinuation;

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      if (optional('await', identifier) && identifier.next!.isIdentifier) {
        // Although the `await` can be used in an expression,
        // it is followed by another identifier which does not form
        // a valid expression. Report an error on the `await` token
        // rather than the token following it.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateUnexpectedToken);

        // TODO(danrubel) Consider a new listener event so that analyzer
        // can represent this as an await expression in a context that does
        // not allow await.
        return identifier.next!;
      } else {}
      return identifier;
    }

    // Recovery
    Token reportErrorAt = identifier;
    if (optional(r'$', token) &&
        identifier.isKeyword &&
        identifier.next!.kind == STRING_TOKEN) {
      // Keyword used as identifier in string interpolation
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifierButGotKeyword);
      return identifier;
    } else if (!looksLikeStatementStart(identifier)) {
      if (identifier.isKeywordOrIdentifier) {
        if (isContinuation || !isOneOfOrEof(identifier, const ['as', 'is'])) {
          // Use the keyword as the identifier.
          parser.reportRecoverableErrorWithToken(
              identifier, codes.templateExpectedIdentifierButGotKeyword);
          return identifier;
        }
      } else if (!identifier.isOperator &&
          !isOneOfOrEof(identifier,
              const ['.', ',', '(', ')', '[', ']', '{', '}', '?', ':', ';'])) {
        // When in doubt, consume the token to ensure we make progress
        token = identifier;
        identifier = token.next!;
      }
    }

    parser.reportRecoverableErrorWithToken(
        reportErrorAt, codes.templateExpectedIdentifier);

    // Insert a synthetic identifier to satisfy listeners.
    return parser.rewriter.insertSyntheticIdentifier(token);
  }
}

/// See [IdentifierContext.extensionShowHideElementGetter],
/// [IdentifierContext.extensionShowHideElementMemberOrType],
/// [IdentifierContext.extensionShowHideElementOperator],
/// [IdentifierContext.extensionShowHideElementSetter].
class ExtensionShowHideElementIdentifierContext extends IdentifierContext {
  static const int _getterKind = 0;
  static const int _memberOrTypeKind = 1;
  static const int _operator = 2;
  static const int _setterKind = 3;

  final int _kind;

  const ExtensionShowHideElementIdentifierContext.getter()
      : _kind = _getterKind,
        super('extensionShowHideElementGetter', inDeclaration: true);

  const ExtensionShowHideElementIdentifierContext.memberOrType()
      : _kind = _memberOrTypeKind,
        super('extensionShowHideElementMemberOrType', inDeclaration: true);

  const ExtensionShowHideElementIdentifierContext.operator()
      : _kind = _operator,
        super('extensionShowHideElementOperator', inDeclaration: true);

  const ExtensionShowHideElementIdentifierContext.setter()
      : _kind = _setterKind,
        super('extensionShowHideElementSetter', inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    if (identifier.isIdentifier ||
        _kind == _operator && identifier.isOperator) {
      return identifier;
    }

    // Recovery
    const List<String> afterIdentifier = const [
      '<',
      '{',
      'extends',
      'with',
      'implements',
      'on',
      '=',
    ];
    if (identifier.isEof ||
        (looksLikeStartOfNextTopLevelDeclaration(identifier) &&
            (identifier.next == null ||
                !isOneOfOrEof(identifier.next!, afterIdentifier))) ||
        (isOneOfOrEof(identifier, afterIdentifier) &&
            (identifier.next == null ||
                !isOneOfOrEof(identifier.next!, afterIdentifier)))) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }

  @override
  bool operator ==(dynamic other) {
    return other is ExtensionShowHideElementIdentifierContext &&
        _kind == other._kind;
  }
}

/// See [IdentifierContext.fieldDeclaration].
class FieldDeclarationIdentifierContext extends IdentifierContext {
  const FieldDeclarationIdentifierContext()
      : super('fieldDeclaration', inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const [';', '=', ',', '}']) ||
        looksLikeStartOfNextClassMember(identifier)) {
      // TODO(jensj): Why aren't an error reported here?
      return parser.insertSyntheticIdentifier(token, this);
    } else if (!identifier.isKeywordOrIdentifier) {
      // When in doubt, consume the token to ensure we make progress
      // but insert a synthetic identifier to satisfy listeners.
      return parser.insertSyntheticIdentifier(identifier, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier),
          messageOnToken: identifier);
    } else {
      // Use the keyword as the identifier.
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifierButGotKeyword);
      return identifier;
    }
  }

  Token ensureIdentifierPotentiallyRecovered(
      Token token, Parser parser, bool isRecovered) {
    // Fast path good case.
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }
    // If not recovered, recover as normal.
    if (!isRecovered || !identifier.isKeywordOrIdentifier) {
      return ensureIdentifier(token, parser);
    }

    // If already recovered, use the given token.
    parser.reportRecoverableErrorWithToken(
        identifier, codes.templateExpectedIdentifierButGotKeyword);
    return identifier;
  }
}

/// See [IdentifierContext.fieldInitializer].
class FieldInitializerIdentifierContext extends IdentifierContext {
  const FieldInitializerIdentifierContext()
      : super('fieldInitializer', isContinuation: true);

  @override
  bool get allowsNewAsIdentifier => true;

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    assert(optional('.', token));
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    parser.reportRecoverableErrorWithToken(
        identifier, codes.templateExpectedIdentifier);
    // Insert a synthetic identifier to satisfy listeners.
    return parser.rewriter.insertSyntheticIdentifier(token);
  }
}

/// See [IdentifierContext.formalParameterDeclaration].
class FormalParameterDeclarationIdentifierContext extends IdentifierContext {
  const FormalParameterDeclarationIdentifierContext()
      : super('formalParameterDeclaration', inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    const List<String> followingValues = const [
      ':',
      '=',
      ',',
      '(',
      ')',
      '[',
      ']',
      '{',
      '}',
    ];
    if (((looksLikeStartOfNextTopLevelDeclaration(identifier) ||
                looksLikeStartOfNextClassMember(identifier) ||
                looksLikeStatementStart(identifier)) &&
            !isOneOf(identifier.next!, okNextValueInFormalParameter)) ||
        isOneOfOrEof(identifier, followingValues)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

class LiteralSymbolIdentifierContext extends IdentifierContext {
  const LiteralSymbolIdentifierContext()
      : super('literalSymbol', inSymbol: true);

  const LiteralSymbolIdentifierContext.continuation()
      : super('literalSymbolContinuation',
            inSymbol: true, isContinuation: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (!identifier.isKeywordOrIdentifier) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      // Use the keyword as the identifier.
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifierButGotKeyword);
    }

    return identifier;
  }
}

/// See [IdentifierContext.localFunctionDeclaration]
/// and [IdentifierContext.localFunctionDeclarationContinuation].
class LocalFunctionDeclarationIdentifierContext extends IdentifierContext {
  const LocalFunctionDeclarationIdentifierContext()
      : super('localFunctionDeclaration', inDeclaration: true);

  const LocalFunctionDeclarationIdentifierContext.continuation()
      : super('localFunctionDeclarationContinuation',
            inDeclaration: true, isContinuation: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const ['.', '(', '{', '=>']) ||
        looksLikeStatementStart(identifier)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.labelDeclaration].
class LabelDeclarationIdentifierContext extends IdentifierContext {
  const LabelDeclarationIdentifierContext()
      : super('labelDeclaration', inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const [':']) ||
        looksLikeStatementStart(identifier)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.labelReference].
class LabelReferenceIdentifierContext extends IdentifierContext {
  const LabelReferenceIdentifierContext() : super('labelReference');

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const [';'])) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.localVariableDeclaration].
class LocalVariableDeclarationIdentifierContext extends IdentifierContext {
  const LocalVariableDeclarationIdentifierContext()
      : super('localVariableDeclaration', inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const [';', '=', ',', '{', '}']) ||
        looksLikeStatementStart(identifier) ||
        identifier.kind == STRING_TOKEN) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.methodDeclaration],
/// and [IdentifierContext.methodDeclarationContinuation],
/// and [IdentifierContext.operatorName].
class MethodDeclarationIdentifierContext extends IdentifierContext {
  const MethodDeclarationIdentifierContext()
      : super('methodDeclaration', inDeclaration: true);

  const MethodDeclarationIdentifierContext.continuation()
      : super('methodDeclarationContinuation',
            inDeclaration: true, isContinuation: true);

  const MethodDeclarationIdentifierContext.operatorName()
      : super('operatorName', inDeclaration: true);

  @override
  bool get allowsNewAsIdentifier => isContinuation;

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (!isContinuation) {
      return parser.insertSyntheticIdentifier(identifier, this,
          message: codes.messageMissingOperatorKeyword,
          messageOnToken: identifier);
    } else if (isOneOfOrEof(identifier, const ['.', '(', '{', '=>', '}']) ||
        looksLikeStartOfNextClassMember(identifier)) {
      return parser.insertSyntheticIdentifier(token, this);
    } else if (!identifier.isKeywordOrIdentifier) {
      // When in doubt, consume the token to ensure we make progress
      // but insert a synthetic identifier to satisfy listeners.
      return parser.insertSyntheticIdentifier(identifier, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier),
          messageOnToken: identifier);
    } else {
      // Use the keyword as the identifier.
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifierButGotKeyword);
      return identifier;
    }
  }

  @override
  Token ensureIdentifierPotentiallyRecovered(
      Token token, Parser parser, bool isRecovered) {
    // Fast path good case.
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }
    // If not recovered, recover as normal.
    if (!isRecovered || !identifier.isKeywordOrIdentifier) {
      return ensureIdentifier(token, parser);
    }

    // If already recovered, use the given token.
    parser.reportRecoverableErrorWithToken(
        identifier, codes.templateExpectedIdentifierButGotKeyword);
    return identifier;
  }
}

/// See [IdentifierContext.namedArgumentReference].
class NamedArgumentReferenceIdentifierContext extends IdentifierContext {
  const NamedArgumentReferenceIdentifierContext()
      : super('namedArgumentReference', allowedInConstantExpression: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.isIdentifier) {
      return identifier;
    }

    // Recovery
    if (isOneOfOrEof(identifier, const [':'])) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

/// See [IdentifierContext.topLevelFunctionDeclaration]
/// and [IdentifierContext.topLevelVariableDeclaration].
class TopLevelDeclarationIdentifierContext extends IdentifierContext {
  final List<String> followingValues;

  const TopLevelDeclarationIdentifierContext(String name, this.followingValues)
      : super(name, inDeclaration: true);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);

    if (identifier.isIdentifier) {
      Token next = identifier.next!;
      if (!looksLikeStartOfNextTopLevelDeclaration(identifier) ||
          isOneOfOrEof(next, followingValues)) {
        return identifier;
      }
      // Although this is a valid top level name, the declaration
      // is invalid and this looks like the start of the next declaration.
      // In this situation, fall through to insert a synthetic name.
    }

    // Recovery
    if (looksLikeStartOfNextTopLevelDeclaration(identifier) ||
        isOneOfOrEof(identifier, followingValues)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else if (identifier.type.isBuiltIn) {
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateBuiltInIdentifierInDeclaration);
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }

  Token ensureIdentifierPotentiallyRecovered(
      Token token, Parser parser, bool isRecovered) {
    // Fast path good case.
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);

    if (identifier.isIdentifier) {
      Token next = identifier.next!;
      if (!looksLikeStartOfNextTopLevelDeclaration(identifier) ||
          isOneOfOrEof(next, followingValues)) {
        return identifier;
      }
    }
    // If not recovered, recover as normal.
    if (!isRecovered || !identifier.isKeywordOrIdentifier) {
      return ensureIdentifier(token, parser);
    }

    // If already recovered, use the given token.
    parser.reportRecoverableErrorWithToken(
        identifier, codes.templateExpectedIdentifierButGotKeyword);
    return identifier;
  }
}

/// See [IdentifierContext.typedefDeclaration].
class TypedefDeclarationIdentifierContext extends IdentifierContext {
  const TypedefDeclarationIdentifierContext()
      : super('typedefDeclaration',
            inDeclaration: true, isBuiltInIdentifierAllowed: false);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.type.isPseudo) {
      if (optional('Function', identifier)) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
      return identifier;
    }

    // Recovery
    const List<String> followingValues = const ['(', '<', '=', ';'];
    if (identifier.type.isBuiltIn &&
        isOneOfOrEof(identifier.next!, followingValues)) {
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateBuiltInIdentifierInDeclaration);
    } else if (looksLikeStartOfNextTopLevelDeclaration(identifier) ||
        isOneOfOrEof(identifier, followingValues)) {
      identifier = parser.insertSyntheticIdentifier(token, this,
          message: codes.templateExpectedIdentifier.withArguments(identifier));
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }

  Token ensureIdentifierPotentiallyRecovered(
      Token token, Parser parser, bool isRecovered) {
    // Fast path good case.
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.type.isPseudo) {
      if (optional('Function', identifier)) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
      return identifier;
    }

    // If not recovered, recover as normal.
    if (!isRecovered || !identifier.isKeywordOrIdentifier) {
      return ensureIdentifier(token, parser);
    }

    // If already recovered, use the given token.
    parser.reportRecoverableErrorWithToken(
        identifier, codes.templateExpectedIdentifierButGotKeyword);
    return identifier;
  }
}

/// See [IdentifierContext.typeReference].
class TypeReferenceIdentifierContext extends IdentifierContext {
  const TypeReferenceIdentifierContext()
      : super('typeReference',
            isScopeReference: true,
            isBuiltInIdentifierAllowed: false,
            recoveryTemplate: codes.templateExpectedType);

  const TypeReferenceIdentifierContext.continuation()
      : super('typeReferenceContinuation',
            isContinuation: true, isBuiltInIdentifierAllowed: false);

  const TypeReferenceIdentifierContext.prefixed()
      : super('prefixedTypeReference',
            isScopeReference: true,
            isBuiltInIdentifierAllowed: true,
            recoveryTemplate: codes.templateExpectedType);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token next = token.next!;
    assert(next.kind != IDENTIFIER_TOKEN);
    if (isValidTypeReference(next)) {
      return next;
    } else if (next.isKeywordOrIdentifier) {
      if (optional("void", next)) {
        parser.reportRecoverableError(next, codes.messageInvalidVoid);
      } else if (next.type.isBuiltIn) {
        if (!isBuiltInIdentifierAllowed) {
          parser.reportRecoverableErrorWithToken(
              next, codes.templateBuiltInIdentifierAsType);
        }
      } else if (optional('var', next)) {
        parser.reportRecoverableError(next, codes.messageVarAsTypeName);
      } else {
        parser.reportRecoverableErrorWithToken(
            next, codes.templateExpectedType);
      }
      return next;
    }
    parser.reportRecoverableErrorWithToken(next, codes.templateExpectedType);
    if (!isOneOfOrEof(
        next, const ['<', '>', ')', '[', ']', '[]', '{', '}', ',', ';'])) {
      // When in doubt, consume the token to ensure we make progress
      token = next;
      next = token.next!;
    }
    // Insert a synthetic identifier to satisfy listeners.
    return parser.rewriter.insertSyntheticIdentifier(token);
  }
}

// See [IdentifierContext.typeVariableDeclaration].
class TypeVariableDeclarationIdentifierContext extends IdentifierContext {
  const TypeVariableDeclarationIdentifierContext()
      : super('typeVariableDeclaration',
            inDeclaration: true, isBuiltInIdentifierAllowed: false);

  @override
  Token ensureIdentifier(Token token, Parser parser) {
    Token identifier = token.next!;
    assert(identifier.kind != IDENTIFIER_TOKEN);
    if (identifier.type.isPseudo) {
      return identifier;
    }

    // Recovery: If the next token  (the one currently in 'identifier') is any
    // of these values we don't "eat" the it but instead insert an identifier
    // between "token" and "token.next" and return that as the last consumed
    // token. Otherwise such a token would be consumed: an identifier would be
    // inserted after "token.next" and that would be returned as the last
    // consumed token, effectively skipping the token.
    const List<String> followingValues = const [
      '<',
      '>',
      '>>',
      '>>>',
      ';',
      '}',
      'extends',
      'super',
      // If currently adding type variables to a typedef this could easily
      // occur and we don't want to 'eat' the equal sign.
      '=',
      '>=',
    ];
    if (looksLikeStartOfNextTopLevelDeclaration(identifier) ||
        looksLikeStartOfNextClassMember(identifier) ||
        looksLikeStatementStart(identifier) ||
        isOneOfOrEof(identifier, followingValues)) {
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateExpectedIdentifier);
      identifier = parser.rewriter.insertSyntheticIdentifier(token);
    } else if (identifier.type.isBuiltIn) {
      parser.reportRecoverableErrorWithToken(
          identifier, codes.templateBuiltInIdentifierInDeclaration);
    } else {
      if (!identifier.isKeywordOrIdentifier) {
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifier);
        // When in doubt, consume the token to ensure we make progress
        // but insert a synthetic identifier to satisfy listeners.
        identifier = parser.rewriter.insertSyntheticIdentifier(identifier);
      } else {
        // Use the keyword as the identifier.
        parser.reportRecoverableErrorWithToken(
            identifier, codes.templateExpectedIdentifierButGotKeyword);
      }
    }
    return identifier;
  }
}

bool looksLikeStartOfNextClassMember(Token token) =>
    isOneOfOrEof(token, const ['@', 'get', 'set', 'void']);

bool looksLikeStartOfNextTopLevelDeclaration(Token token) =>
    isOneOfOrEof(token, const ['const', 'get', 'final', 'set', 'var', 'void']);
