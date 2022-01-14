// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/token.dart';

import '../messages/codes.dart' as codes;
import 'formal_parameter_kind.dart';
import 'member_kind.dart' show MemberKind;
import 'parser.dart';
import 'util.dart' show optional;

bool isModifier(Token token) {
  if (token.type.isBuiltIn) {
    // A built-in keyword can only be a modifier as long as it is
    // followed by another keyword or an identifier. Otherwise, it is the
    // identifier.
    //
    // For example, `external` is a modifier in this declaration:
    //   external Foo foo();
    // but is the identifier in this declaration
    //   external() => true;
    // and in
    //   for (final external in list) { }
    Token next = token.next!;
    if (!next.isKeyword && !next.isIdentifier) {
      return false;
    }
  }
  return true;
}

/// This class is used to parse modifiers in most locations where modifiers
/// can occur, but does not call handleModifier or handleModifiers.
class ModifierRecoveryContext {
  final Parser parser;
  Token? abstractToken;
  Token? constToken;
  Token? covariantToken;
  Token? externalToken;
  Token? finalToken;
  Token? lateToken;
  Token? requiredToken;
  Token? staticToken;
  Token? varToken;

  // Set `true` when parsing modifiers after the `factory` token.
  bool afterFactory = false;

  // TODO(danrubel): Replace [ModifierRecoveryContext] and [ModifierContext]
  // with this class.

  ModifierRecoveryContext(this.parser);

  set staticOrCovariant(Token? staticOrCovariant) {
    if (staticOrCovariant == null) {
      covariantToken = null;
      staticToken = null;
    } else if (optional('covariant', staticOrCovariant)) {
      covariantToken = staticOrCovariant;
      staticToken = null;
    } else if (optional('static', staticOrCovariant)) {
      covariantToken = null;
      staticToken = staticOrCovariant;
    } else {
      throw "Internal error: "
          "Unexpected staticOrCovariant '$staticOrCovariant'.";
    }
  }

  Token? get varFinalOrConst => varToken ?? finalToken ?? constToken;

  set varFinalOrConst(Token? varFinalOrConst) {
    if (varFinalOrConst == null) {
      varToken = null;
      finalToken = null;
      constToken = null;
    } else if (optional('var', varFinalOrConst)) {
      varToken = varFinalOrConst;
      finalToken = null;
      constToken = null;
    } else if (optional('final', varFinalOrConst)) {
      varToken = null;
      finalToken = varFinalOrConst;
      constToken = null;
    } else if (optional('const', varFinalOrConst)) {
      varToken = null;
      finalToken = null;
      constToken = varFinalOrConst;
    } else {
      throw "Internal error: Unexpected varFinalOrConst '$varFinalOrConst'.";
    }
  }

  /// Parse modifiers for class methods and fields.
  Token parseClassMemberModifiers(Token token) {
    token = parseModifiers(token);
    reportExtraneousModifier(requiredToken);
    return token;
  }

  /// Parse modifiers for formal parameters.
  Token parseFormalParameterModifiers(
      Token token, FormalParameterKind parameterKind, MemberKind memberKind) {
    token = parseModifiers(token);

    if (parameterKind != FormalParameterKind.optionalNamed) {
      reportExtraneousModifier(requiredToken);
    }
    if (memberKind == MemberKind.StaticMethod ||
        memberKind == MemberKind.TopLevelMethod) {
      reportExtraneousModifier(this.covariantToken);
    } else if (memberKind == MemberKind.ExtensionNonStaticMethod ||
        memberKind == MemberKind.ExtensionStaticMethod) {
      reportExtraneousModifierInExtension(this.covariantToken);
    }
    if (constToken != null) {
      reportExtraneousModifier(constToken);
    } else if (memberKind == MemberKind.GeneralizedFunctionType) {
      if (varFinalOrConst != null) {
        parser.reportRecoverableError(
            varFinalOrConst!, codes.messageFunctionTypedParameterVar);
      }
    }
    reportExtraneousModifier(abstractToken);
    reportExtraneousModifier(externalToken);
    reportExtraneousModifier(lateToken);
    reportExtraneousModifier(staticToken);
    return token;
  }

  /// Parse modifiers after the `factory` token.
  Token parseModifiersAfterFactory(Token token) {
    afterFactory = true;
    token = parseModifiers(token);
    if (abstractToken != null) {
      parser.reportRecoverableError(
          abstractToken!, codes.messageAbstractClassMember);
    }
    reportExtraneousModifier(lateToken);
    reportExtraneousModifier(requiredToken);
    return token;
  }

  /// Parse modifiers for top level functions and fields.
  Token parseTopLevelModifiers(Token token) {
    token = parseModifiers(token);
    reportExtraneousModifier(abstractToken);
    reportExtraneousModifier(covariantToken);
    reportExtraneousModifier(requiredToken);
    reportExtraneousModifier(staticToken);
    return token;
  }

  /// Parse modifiers for variable declarations.
  Token parseVariableDeclarationModifiers(Token token) {
    token = parseModifiers(token);
    reportExtraneousModifier(abstractToken);
    reportExtraneousModifier(covariantToken);
    reportExtraneousModifier(externalToken);
    reportExtraneousModifier(requiredToken);
    reportExtraneousModifier(staticToken);
    return token;
  }

  /// Parse modifiers during recovery when modifiers are out of order
  /// or invalid. Typically clients call methods like
  /// [parseClassMemberModifiers] which in turn calls this method,
  /// rather than calling this method directly.
  ///
  /// The various modifier token parameters represent tokens of modifiers
  /// that have already been parsed prior to recovery. The [staticOrCovariant]
  /// parameter is for convenience if caller has a token that may be either
  /// `static` or `covariant`. The first non-null parameter of
  /// [staticOrCovariant], [staticToken], or [covariantToken] will be used,
  /// in that order, and the others ignored.
  Token parseModifiers(Token token) {
    // Process invalid and out-of-order modifiers
    Token next = token.next!;
    while (true) {
      final String? value = next.toString();

      if (identical('var', value)) {
        token = parseVar(token);
      } else {
        break;
      }
      next = token.next!;
    }
    return token;
  }

  Token parseVar(Token token) {
    Token next = token.next!;
    assert(optional('var', next));
    if (varFinalOrConst == null && !afterFactory) {
      varToken = next;
      return next;
    }

    // Recovery
    if (varToken != null) {
      parser.reportRecoverableErrorWithToken(
          next, codes.templateDuplicatedModifier);
    } else if (afterFactory) {
      reportExtraneousModifier(next);
    } else if (constToken != null) {
      reportConflictingModifiers(next, constToken!);
    } else if (finalToken != null) {
      parser.reportRecoverableError(next, codes.messageFinalAndVar);
    } else {
      throw 'Internal Error: Unexpected varFinalOrConst: $varFinalOrConst';
    }
    return next;
  }

  void reportConflictingModifiers(Token modifier, Token earlierModifier) {
    parser.reportRecoverableError(
        modifier,
        codes.templateConflictingModifiers
            .withArguments(modifier.lexeme, earlierModifier.lexeme));
  }

  void reportExtraneousModifier(Token? modifier) {
    if (modifier != null) {
      parser.reportRecoverableErrorWithToken(
          modifier, codes.templateExtraneousModifier);
    }
  }

  void reportExtraneousModifierInExtension(Token? modifier) {
    if (modifier != null) {
      parser.reportRecoverableErrorWithToken(
          modifier, codes.templateExtraneousModifierInExtension);
    }
  }

  void reportModifierOutOfOrder(Token modifier, String beforeModifier) {
    parser.reportRecoverableError(
        modifier,
        codes.templateModifierOutOfOrder
            .withArguments(modifier.lexeme, beforeModifier));
  }
}
