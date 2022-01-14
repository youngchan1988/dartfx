// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/util/logger.dart';

const _tag = 'AstNode';

enum AstRuntimeNodeName {
  SimpleIdentifier,
  PrefixedIdentifier,
  DoubleLiteral,
  IntegerLiteral,
  StringLiteral,
  BooleanLiteral,
  SetOrMapLiteral,
  MapLiteralEntry,
  ListLiteral,
  NullLiteral,
  NamedExpression,
  MemberExpression,
  MethodInvocation,
  FieldDeclaration,
  Annotation,
  PropertyAccess,
  IfStatement,
  ForStatement,
  SwitchStatement,
  SwitchCase,
  SwitchDefault,
  ReturnStatement,
  Block,
  FormalParameterList,
  SimpleFormalParameter,
  DefaultFormalParameter,
  FieldFormalParameter,
  TypeName,
  BlockFunctionBody,
  ExpressionFunctionBody,
  ClassDeclaration,
  ImplementsClause,
  WithClause,
  FunctionDeclaration,
  MethodDeclaration,
  VariableDeclaration,
  VariableDeclarationList,
  BinaryExpression,
  AssignmentExpression,
  FunctionExpression,
  PrefixExpression,
  AwaitExpression,
  ExpressionStatement,
  IndexExpression,
  FunctionExpressionInvocation,
  Program,
  AsExpression,
  IsExpression,
  StringInterpolation,
  InterpolationString,
  InterpolationExpression,
  //注解类声明
  FHClassAnnotation,
  ConditionalExpression,
  SuperExpression,
  SuperConstructorInvocation,
  ThisExpression,
  BreakStatement,
  ConstructorDeclaration,
  ConstructorFieldInitializer,
  InstanceCreationExpression,
  ConstructorName,
}

String astNodeNameValue(AstRuntimeNodeName nodeName) =>
    nodeName.toString().split('.')[1];

class AstRuntimeNodeParser {
  static AstRuntimeNode? fromAst(Map? ast) {
    if (ast == null) {
      return null;
    }
    AstRuntimeNodeName? nodeName;
    for (var type in AstRuntimeNodeName.values) {
      if (ast['type'] == astNodeNameValue(type)) {
        nodeName = type;
        break;
      }
    }
    switch (nodeName) {
      case AstRuntimeNodeName.SimpleIdentifier:
        return SimpleIdentifier.fromAst(ast);
      case AstRuntimeNodeName.PrefixedIdentifier:
        return PrefixedIdentifier.fromAst(ast);
      case AstRuntimeNodeName.DoubleLiteral:
        return DoubleLiteral.fromAst(ast);
      case AstRuntimeNodeName.IntegerLiteral:
        return IntegerLiteral.fromAst(ast);
      case AstRuntimeNodeName.StringLiteral:
        return StringLiteral.fromAst(ast);
      case AstRuntimeNodeName.BooleanLiteral:
        return BooleanLiteral.fromAst(ast);
      case AstRuntimeNodeName.SetOrMapLiteral:
        return SetOrMapLiteral.fromAst(ast);
      case AstRuntimeNodeName.MapLiteralEntry:
        return MapLiteralEntry.fromAst(ast);
      case AstRuntimeNodeName.ListLiteral:
        return ListLiteral.fromAst(ast);
      case AstRuntimeNodeName.NullLiteral:
        return NullLiteral.fromAst(ast);
      case AstRuntimeNodeName.NamedExpression:
        return NamedExpression.fromAst(ast);
      case AstRuntimeNodeName.MemberExpression:
        return MemberExpression.fromAst(ast);
      case AstRuntimeNodeName.MethodInvocation:
        return MethodInvocation.fromAst(ast);
      case AstRuntimeNodeName.FieldDeclaration:
        return FieldDeclaration.fromAst(ast);
      case AstRuntimeNodeName.Annotation:
        return Annotation.fromAst(ast);
      case AstRuntimeNodeName.PropertyAccess:
        return PropertyAccess.fromAst(ast);
      case AstRuntimeNodeName.IfStatement:
        return IfStatement.fromAst(ast);
      case AstRuntimeNodeName.ForStatement:
        return ForStatement.fromAst(ast);
      case AstRuntimeNodeName.SwitchStatement:
        return SwitchStatement.fromAst(ast);
      case AstRuntimeNodeName.SwitchCase:
        return SwitchCase.fromAst(ast);
      case AstRuntimeNodeName.SwitchDefault:
        return SwitchCase.fromAst(ast);
      case AstRuntimeNodeName.ReturnStatement:
        return ReturnStatement.fromAst(ast);
      case AstRuntimeNodeName.Block:
        return Block.fromAst(ast);
      case AstRuntimeNodeName.FormalParameterList:
        return FormalParameterList.fromAst(ast);
      case AstRuntimeNodeName.SimpleFormalParameter:
        return SimpleFormalParameter.fromAst(ast);
      case AstRuntimeNodeName.DefaultFormalParameter:
        return DefaultFormalParameter.fromAst(ast);
      case AstRuntimeNodeName.TypeName:
        return TypeName.fromAst(ast);
      case AstRuntimeNodeName.BlockFunctionBody:
        return BlockFunctionBody.fromAst(ast);
      case AstRuntimeNodeName.ExpressionFunctionBody:
        return ExpressionFunctionBody.fromAst(ast);
      case AstRuntimeNodeName.ClassDeclaration:
        return ClassDeclaration.fromAst(ast);
      case AstRuntimeNodeName.ImplementsClause:
        return ImplementsClause.fromAst(ast);
      case AstRuntimeNodeName.WithClause:
        return WithClause.fromAst(ast);
      case AstRuntimeNodeName.FunctionDeclaration:
        return FunctionDeclaration.fromAst(ast);
      case AstRuntimeNodeName.MethodDeclaration:
        return MethodDeclaration.fromAst(ast);
      case AstRuntimeNodeName.VariableDeclaration:
        return VariableDeclaration.fromAst(ast);
      case AstRuntimeNodeName.VariableDeclarationList:
        return VariableDeclarationList.fromAst(ast);
      case AstRuntimeNodeName.BinaryExpression:
        return BinaryExpression.fromAst(ast);
      case AstRuntimeNodeName.AssignmentExpression:
        return AssignmentExpression.fromAst(ast);
      case AstRuntimeNodeName.FunctionExpression:
        return FunctionExpression.fromAst(ast);
      case AstRuntimeNodeName.PrefixExpression:
        return PrefixExpression.fromAst(ast);
      case AstRuntimeNodeName.AwaitExpression:
        return AwaitExpression.fromAst(ast);
      case AstRuntimeNodeName.ExpressionStatement:
        return ExpressionStatement.fromAst(ast);
      case AstRuntimeNodeName.IndexExpression:
        return IndexExpression.fromAst(ast);
      case AstRuntimeNodeName.FunctionExpressionInvocation:
        return FunctionExpressionInvocation.fromAst(ast);
      case AstRuntimeNodeName.Program:
        return Program.fromAst(ast);
      case AstRuntimeNodeName.AsExpression:
        return AsExpression.fromAst(ast);
      case AstRuntimeNodeName.IsExpression:
        return IsExpression.fromAst(ast);
      case AstRuntimeNodeName.StringInterpolation:
        return StringInterpolation.fromAst(ast);
      case AstRuntimeNodeName.InterpolationString:
        return InterpolationString.fromAst(ast);
      case AstRuntimeNodeName.InterpolationExpression:
        return InterpolationExpression.fromAst(ast);
      case AstRuntimeNodeName.FHClassAnnotation:
        return FHAstAnnotation.fromAst(ast);
      case AstRuntimeNodeName.ConditionalExpression:
        return ConditionalExpression.fromAst(ast);
      case AstRuntimeNodeName.SuperExpression:
        return SuperExpression.fromAst(ast);
      case AstRuntimeNodeName.SuperConstructorInvocation:
        return SuperConstructorInvocation.fromAst(ast);
      case AstRuntimeNodeName.ThisExpression:
        return ThisExpression.fromAst(ast);
      case AstRuntimeNodeName.BreakStatement:
        return BreakStatement.fromAst(ast);
      case AstRuntimeNodeName.ConstructorDeclaration:
        return ConstructorDeclaration.fromAst(ast);
      case AstRuntimeNodeName.ConstructorFieldInitializer:
        return ConstructorFieldInitializer.fromAst(ast);
      case AstRuntimeNodeName.InstanceCreationExpression:
        return InstanceCreationExpression.fromAst(ast);
      case AstRuntimeNodeName.ConstructorName:
        return ConstructorName.fromAst(ast);
      case AstRuntimeNodeName.FieldFormalParameter:
        return FieldFormalParameter.fromAst(ast);
      default:
        logDebug(_tag, 'Unsupported ast node: ${nodeName.toString()}');
        return NullLiteral();
    }
  }
}

/// A node in the AST structure for a Dart program.
///
/// Clients may not extend, implement or mix-in this class.
abstract class AstRuntimeNode {}

///// A node that represents an expression.
/////
/////    expression ::=
/////        [AssignmentExpression]
/////      | [ConditionalExpression] cascadeSection*
/////      | [ThrowExpression]
/////      | [InterpolationExpression]
/////
///// Clients may not extend, implement or mix-in this class.
//abstract class Expression implements AstNode {
//
//  /// Try to parse and run the current ast node logic. Return `dynamic` type data
//  /// if there is return value. Otherwise return `null`
//  execute(AstContext astContext);
//
//}
//
/// A node that represents a literal expression.
///
///    literal ::=
///        [BooleanLiteral]
///      | [DoubleLiteral]
///      | [IntegerLiteral]
///      | [ListLiteral]
///      | [NullLiteral]
///      | [SetOrMapLiteral]
///      | [StringLiteral]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Literal implements AstRuntimeNode {
  get value;
}

///// A node that represents a statement.
/////
/////    statement ::=
/////        [Block]
/////      | [VariableDeclarationStatement]
/////      | [ForStatement]
/////      | [ForEachStatement]
/////      | [WhileStatement]
/////      | [DoStatement]
/////      | [SwitchStatement]
/////      | [IfStatement]
/////      | [TryStatement]
/////      | [BreakStatement]
/////      | [ContinueStatement]
/////      | [ReturnStatement]
/////      | [ExpressionStatement]
/////      | [FunctionDeclarationStatement]
/////
///// Clients may not extend, implement or mix-in this class.
//abstract class Statement implements AstNode{
//  /// Try to parse and run the current ast node logic. Return `dynamic` type data
//  /// if there is return value. Otherwise return `null`
//  execute(AstContext astContext);
//}

/// A node representing a parameter to a function.
///
///    formalParameter ::=
///        [SimpleFormalParameter]
///      | [DefaultFormalParameter]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FormalParameter implements AstRuntimeNode {
  /// Return the name of the parameter being declared.
  String? get name;

  /// Return `true` if this parameter is a named parameter.
  ///
  /// Named parameters can either be required or optional.
  bool? get isNamed;

  /// Return `true` if this parameter is an optional parameter.
  ///
  /// Optional parameters can either be positional or named.
  bool? get isOptional;

  /// Return `true` if this parameter is both an optional and named parameter.
  bool? get isOptionalNamed;

  /// Return `true` if this parameter is both an optional and positional
  /// parameter.
  bool? get isOptionalPositional;

  /// Return `true` if this parameter is a positional parameter.
  ///
  /// Positional parameters can either be required or optional.
  bool? get isPositional;
}

///  A string interpolation literal.
///  Example: 'My name is $name' OR 'My name is ${person.name}'
///
/// The execute method return a full string
///
class StringInterpolation implements AstRuntimeNode {
  final List<AstRuntimeNode?> elements;

  StringInterpolation(this.elements);

  static StringInterpolation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.StringInterpolation)) {
      var astElements = ast['elements'] as List?;
      var elements = <AstRuntimeNode?>[];
      astElements?.forEach((e) {
        elements.add(AstRuntimeNodeParser.fromAst(e));
      });
      return StringInterpolation(elements);
    }
    logDebug(_tag, 'Can not parse ast to StringInterpolation');
    return null;
  }
}

/// A non-empty substring of an interpolated string.
///
///    interpolationString ::=
///        characters
///
/// Example: 'My name is $name'.
/// The string 'My name is ' is InterpolationString.
///
class InterpolationString implements AstRuntimeNode {
  final String? value;

  InterpolationString(this.value);

  static InterpolationString? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.InterpolationString)) {
      return InterpolationString(ast['value']);
    }
    logDebug(_tag, 'Can not parse ast to InterpolationString');
    return null;
  }
}

/// An expression embedded in a string interpolation.
///
///    interpolationExpression ::=
///        '$' [SimpleIdentifier]
///      | '$' '{' [AstNode] '}'
/// Example: 'My name is $name. I am ${person.age}'.
/// `$name` and `${person.age}` is InterpolationExpression
///
class InterpolationExpression implements AstRuntimeNode {
  final AstRuntimeNode? expression;

  InterpolationExpression(this.expression);

  static InterpolationExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.InterpolationExpression)) {
      return InterpolationExpression(
        AstRuntimeNodeParser.fromAst(ast['value']),
      );
    }
    logDebug(_tag, 'Can not parse ast to InterpolationExpression');
    return null;
  }
}

/// A simple identifier.
///
///    simpleIdentifier ::=
///        initialCharacter internalCharacter*
///
///    initialCharacter ::= '_' | '$' | letter
///
///    internalCharacter ::= '_' | '$' | letter | digit
///
class SimpleIdentifier implements AstRuntimeNode {
  final String? name;

  SimpleIdentifier(this.name);

  static SimpleIdentifier? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.SimpleIdentifier)) {
      return SimpleIdentifier(ast['name']);
    }
    logDebug(_tag, 'Can not parse ast to SimpleIdentifier');
    return null;
  }
}

/// An identifier that is prefixed or an access to an object property where the
/// target of the property access is a simple identifier.
///
///    prefixedIdentifier ::=
///        [String] '.' [String]
///
class PrefixedIdentifier implements AstRuntimeNode {
  final String? identifier;
  final String? prefix;

  PrefixedIdentifier(this.identifier, this.prefix);

  static PrefixedIdentifier? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.PrefixedIdentifier)) {
      return PrefixedIdentifier(ast['identifier'], ast['prefix']);
    }
    logDebug(_tag, 'Can not parse ast to PrefixedIdentifier');
    return null;
  }
}

/// A string literal expression.
///
class StringLiteral implements Literal {
  final String? _value;

  StringLiteral(this._value);

  static StringLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.StringLiteral)) {
      return StringLiteral(ast['value']);
    }
    logDebug(_tag, 'Can not parse ast to StringLiteral');
    return null;
  }

  @override
  get value => _value;
}

/// A floating point literal expression.
///
class DoubleLiteral implements Literal {
  final double? _value;

  DoubleLiteral(this._value);

  static DoubleLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.DoubleLiteral)) {
      return DoubleLiteral(ast['value']);
    }
    logDebug(_tag, 'Can not parse ast to DoubleLiteral');
    return null;
  }

  @override
  get value => _value;
}

/// An integer literal expression.
///
class IntegerLiteral implements Literal {
  final int? _value;

  IntegerLiteral(this._value);

  static IntegerLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.IntegerLiteral)) {
      return IntegerLiteral(ast['value']);
    }
    logDebug(_tag, 'Can not parse ast to IntegerLiteral');
    return null;
  }

  @override
  get value => _value;
}

/// A boolean literal expression.
///
class BooleanLiteral implements Literal {
  final bool? _value;

  BooleanLiteral(this._value);

  static BooleanLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.BooleanLiteral)) {
      return BooleanLiteral(ast['value']);
    }
    logDebug(_tag, 'Can not parse ast to BooleanLiteral');
    return null;
  }

  @override
  get value => _value;
}

/// A single key/value pair in a map literal.
///
///    mapLiteralEntry ::=
///        [AstNode] ':' [AstNode]
///
class MapLiteralEntry implements AstRuntimeNode {
  Literal? key;
  AstRuntimeNode? value;

  MapLiteralEntry(this.key, this.value);

  static MapLiteralEntry? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.MapLiteralEntry)) {
      return MapLiteralEntry(
          AstRuntimeNodeParser.fromAst(ast['key']) as Literal?,
          AstRuntimeNodeParser.fromAst(ast['value']));
    }
    logDebug(_tag, 'Can not parse ast to MapLiteralEntry');
    return null;
  }
}

/// A set or map literal.
///
///    setOrMapLiteral ::=
///        'const'? [TypeArgumentList]? '{' elements? '}'
///
///    elements ::=
///        [AstNode] ( ',' [AstNode] )* ','?
///
/// This is the class that is used to represent either a map or set literal when
/// either the 'control-flow-collections' or 'spread-collections' experiments
/// are enabled. If neither of those experiments are enabled, then `MapLiteral`
/// will be used to represent a map literal and `SetLiteral` will be used for
/// set literals.
///
class SetOrMapLiteral implements Literal {
  List<MapLiteralEntry?> elements;

  SetOrMapLiteral(this.elements);

  static SetOrMapLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.SetOrMapLiteral)) {
      var astElements = ast['elements'] as List?;
      var entries = <MapLiteralEntry?>[];
      astElements?.forEach((element) {
        entries.add(AstRuntimeNodeParser.fromAst(element) as MapLiteralEntry?);
      });
      return SetOrMapLiteral(entries);
    }
    logDebug(_tag, 'Can not parse ast to SetOrMapLiteral');
    return null;
  }

  @override
  get value => {};
}

/// A list literal.
///
///    listLiteral ::=
///        '[' elements? ']'
///
///    elements ::=
///        [AstNode] (',' [AstNode])* ','?
///
class ListLiteral implements Literal {
  List<AstRuntimeNode?> elements;

  ListLiteral(this.elements);

  static ListLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ListLiteral)) {
      var astElements = ast['elements'] as List;
      var items = <AstRuntimeNode?>[];
      for (var e in astElements) {
        items.add(AstRuntimeNodeParser.fromAst(e));
      }
      return ListLiteral(items);
    }
    logDebug(_tag, 'Can not parse ast to ListLiteral');
    return null;
  }

  @override
  get value => [];
}

/// A null literal expression.
///
///    nullLiteral ::=
///        'null'
///
class NullLiteral implements Literal {
  NullLiteral();

  static NullLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.NullLiteral)) {
      return NullLiteral();
    }
    logDebug(_tag, 'Can not parse ast to NullLiteral');
    return null;
  }

  @override
  get value => null;
}

/// An annotation that can be associated with an AST node.
///
///    metadata ::=
///        annotation*
///
///    annotation ::=
///        '@' [SimpleIdentifier] ('.' [SimpleIdentifier])? [ArgumentList]?
///
class Annotation implements AstRuntimeNode {
  SimpleIdentifier? name;
  SimpleIdentifier? constructorName;
  List<AstRuntimeNode?> argumentList;

  Annotation(this.name, this.constructorName, this.argumentList);

  static Annotation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.Annotation)) {
      return Annotation(
          SimpleIdentifier.fromAst(ast['id']),
          SimpleIdentifier.fromAst(ast['constructorName']),
          _parseArgumentList(ast['argumentList']));
    }
    logDebug(_tag, 'Can not parse ast to Annotation');
    return null;
  }
}

/// The callee of MethodInvocation
/// callee ::=
///   (Expression).(SimpleIdentifier)
///
class MemberExpression implements AstRuntimeNode {
  AstRuntimeNode? target;
  String? property;

  MemberExpression(this.target, this.property);

  static MemberExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.MemberExpression)) {
      return MemberExpression(
        AstRuntimeNodeParser.fromAst(ast['target']),
        SimpleIdentifier.fromAst(ast['property'])?.name,
      );
    }
    logDebug(_tag, 'Can not parse ast to MemberExpression');
    return null;
  }
}

/// A simple formal parameter.
///
///    simpleFormalParameter ::=
///        ('final' [TypeAnnotation] | 'var' | [TypeAnnotation])? [SimpleIdentifier]
///
class SimpleFormalParameter implements FormalParameter {
  TypeName? paramType;

  String? _name;

  bool? _isNamed;
  bool? _isPositional;
  bool? _isOptional;
  bool? _isOptionalNamed;
  bool? _isOptionalPositional;

  SimpleFormalParameter(
      this._name,
      this.paramType,
      this._isNamed,
      this._isPositional,
      this._isOptional,
      this._isOptionalNamed,
      this._isOptionalPositional);

  static SimpleFormalParameter? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.SimpleFormalParameter)) {
      return SimpleFormalParameter(
        ast['name'],
        TypeName.fromAst(ast['paramType']),
        ast['isNamed'],
        ast['isPositional'],
        ast['isOptional'],
        ast['isOptionalNamed'],
        ast['isOptionalPositional'],
      );
    }
    logDebug(_tag, 'Can not parse ast to SimpleFormalParameter');
    return null;
  }

  @override
  bool? get isPositional => _isPositional;

  @override
  String? get name => _name;

  @override
  bool? get isNamed => _isNamed;

  @override
  bool? get isOptional => _isOptional;

  @override
  bool? get isOptionalNamed => _isOptionalNamed;

  @override
  bool? get isOptionalPositional => _isOptionalPositional;
}

/// A formal parameter with a default value.
///
/// There are two kinds of parameters that are both represented by this class:
/// named formal parameters and positional formal parameters.
///
///    defaultFormalParameter ::=
///        [name] ('=' [AstNode])?
///
///    defaultNamedParameter ::=
///        [name] (':' [AstNode])?
///
class DefaultFormalParameter implements FormalParameter {
  String? _name;
  AstRuntimeNode? _defaultValue;

  bool? _isNamed;
  bool? _isPositional;
  bool? _isOptional;
  bool? _isOptionalNamed;
  bool? _isOptionalPositional;

  DefaultFormalParameter(
      this._name,
      this._defaultValue,
      this._isNamed,
      this._isPositional,
      this._isOptional,
      this._isOptionalNamed,
      this._isOptionalPositional);

  static DefaultFormalParameter? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.DefaultFormalParameter)) {
      return DefaultFormalParameter(
        ast['name'],
        AstRuntimeNodeParser.fromAst(ast['defaultValue']),
        ast['isNamed'],
        ast['isPositional'],
        ast['isOptional'],
        ast['isOptionalNamed'],
        ast['isOptionalPositional'],
      );
    }
    logDebug(_tag, 'Can not parse ast to DefaultFormalParameter');
    return null;
  }

  AstRuntimeNode? get defaultValue => _defaultValue;

  @override
  bool? get isNamed => _isNamed;

  @override
  bool? get isOptional => _isOptional;

  @override
  bool? get isOptionalNamed => _isOptionalNamed;

  @override
  bool? get isOptionalPositional => _isOptionalPositional;

  @override
  bool? get isPositional => _isPositional;

  @override
  String? get name => _name;
}

/// A field formal parameter.
///
///    fieldFormalParameter ::=
///        ('final' [TypeAnnotation] | 'const' [TypeAnnotation] | 'var' | [TypeAnnotation])?
///        'this' '.' [SimpleIdentifier] ([TypeParameterList]? [FormalParameterList])?
///
class FieldFormalParameter implements FormalParameter {
  String? _name;
  bool haveThisKeyword;
  FormalParameterList? parameterList;

  bool? _isNamed;
  bool? _isPositional;
  bool? _isOptional;
  bool? _isOptionalNamed;
  bool? _isOptionalPositional;

  FieldFormalParameter(
      this._name,
      this.parameterList,
      this.haveThisKeyword,
      this._isNamed,
      this._isPositional,
      this._isOptional,
      this._isOptionalNamed,
      this._isOptionalPositional);

  static FieldFormalParameter? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.FieldFormalParameter)) {
      return FieldFormalParameter(
        ast['name'],
        FormalParameterList.fromAst(ast['parameters']),
        ast['thisKeyword'] ?? false,
        ast['isNamed'],
        ast['isPositional'],
        ast['isOptional'],
        ast['isOptionalNamed'],
        ast['isOptionalPositional'],
      );
    }
    logDebug(_tag, 'Can not parse ast to DefaultFormalParameter');
    return null;
  }

  @override
  bool? get isNamed => _isNamed;

  @override
  bool? get isOptional => _isOptional;

  @override
  bool? get isOptionalNamed => _isOptionalNamed;

  @override
  bool? get isOptionalPositional => _isOptionalPositional;

  @override
  bool? get isPositional => _isPositional;

  @override
  String? get name => _name;
}

/// The formal parameter list of a method declaration, function declaration, or
/// function type alias.
///
/// While the grammar requires all optional formal parameters to follow all of
/// the normal formal parameters and at most one grouping of optional formal
/// parameters, this class does not enforce those constraints. All parameters
/// are flattened into a single list, which can have any or all kinds of
/// parameters (normal, named, and positional) in any order.
///
///    formalParameterList ::=
///        '(' ')'
///      | '(' normalFormalParameters (',' optionalFormalParameters)? ')'
///      | '(' optionalFormalParameters ')'
///
///    formalParameters ::=
///        [FormalParameter] (',' [FormalParameter])*
///
///    optionalFormalParameters ::=
///        optionalPositionalFormalParameters
///      | namedFormalParameters
///
///    optionalPositionalFormalParameters ::=
///        '[' [DefaultFormalParameter] (',' [DefaultFormalParameter])* ']'
///
///    namedFormalParameters ::=
///        '{' [DefaultFormalParameter] (',' [DefaultFormalParameter])* '}'
///
class FormalParameterList implements AstRuntimeNode {
  List<FormalParameter?> parameterList;
  FormalParameterList(this.parameterList);

  static FormalParameterList? fromAst(Map? ast) {
    if (ast != null) {
      if (ast['type'] ==
          astNodeNameValue(AstRuntimeNodeName.FormalParameterList)) {
        var parameterList = ast['parameterList'] as List?;
        var parameters = <FormalParameter?>[];
        parameterList?.forEach((element) {
          parameters
              .add(AstRuntimeNodeParser.fromAst(element) as FormalParameter?);
        });
        return FormalParameterList(parameters);
      } else {
        logDebug(_tag, 'Can not parse ast to FormalParameterList');
      }
    }

    return null;
  }
}

/// The name of a type
///
class TypeName implements AstRuntimeNode {
  String? name;

  TypeName(this.name);

  static TypeName? fromAst(Map? ast) {
    if (ast != null && ast['type'] == 'TypeName') {
      return TypeName(ast['name']);
    }
//    logDebug(_tag, 'Can not parse ast to TypeName');
    return null;
  }
}

/// A sequence of statements.
///
///    block ::=
///        '{' statement* '}'
///
class Block implements AstRuntimeNode {
  ///代码块中各表达式
  List<AstRuntimeNode?> body;

  Block(this.body);

  static Block? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.Block)) {
      var astBody = ast['body'] as List;
      var bodies = <AstRuntimeNode?>[];
      for (var arg in astBody) {
        bodies.add(AstRuntimeNodeParser.fromAst(arg));
      }
      return Block(bodies);
    }
//    logDebug(_tag, 'Can not parse ast to Block');
    return null;
  }
}

/// A node representing the body of a function or method.
///
///    functionBody ::=
///        [BlockFunctionBody]
///      | [ExpressionFunctionBody]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionBody implements AstRuntimeNode {
  /// Return `true` if this function body is asynchronous.
  bool? get isAsynchronous;
}

/// A function body that consists of a block of statements.
///
///    blockFunctionBody ::=
///        ('async' | 'async' '*' | 'sync' '*')? [Block]
///
class BlockFunctionBody implements FunctionBody {
  bool? _isAsynchronous;
  Block? block;

  BlockFunctionBody(this._isAsynchronous, this.block);

  static BlockFunctionBody? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.BlockFunctionBody)) {
      return BlockFunctionBody(
          ast['isAsynchronous'], Block.fromAst(ast['block']));
    }
//    logDebug(_tag, 'Can not parse ast to BlockFunctionBody');
    return null;
  }

  @override
  bool? get isAsynchronous => _isAsynchronous;
}

/// A function body consisting of a single expression.
///
///    expressionFunctionBody ::=
///        'async'? '=>' [AstNode] ';'
///
class ExpressionFunctionBody implements FunctionBody {
  bool? _isAsynchronous;
  AstRuntimeNode? expression;

  ExpressionFunctionBody(this._isAsynchronous, this.expression);

  static ExpressionFunctionBody? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.ExpressionFunctionBody)) {
      return ExpressionFunctionBody(ast['isAsynchronous'],
          AstRuntimeNodeParser.fromAst(ast['expression']));
    }
    logDebug(_tag, 'Can not parse ast to ExpressionFunctionBody');
    return null;
  }

  @override
  bool? get isAsynchronous => _isAsynchronous;
}

/// A method declaration.
///
///    methodDeclaration ::=
///        methodSignature [FunctionBody]
///
///    methodSignature ::=
///        'external'? ('abstract' | 'static')? [Type]? ('get' | 'set')?
///        methodName [TypeParameterList] [FormalParameterList]
///
///    methodName ::=
///        [SimpleIdentifier]
///      | 'operator' [SimpleIdentifier]
///
/// Prior to the 'extension-methods' experiment, these nodes were always
/// children of a class declaration. When the experiment is enabled, these nodes
/// can also be children of an extension declaration.
///
class MethodDeclaration implements AstRuntimeNode {
  String? name;
  FormalParameterList? parameterList;
  FunctionBody? body;
  TypeName? returnType;
  bool? isGetter;
  bool? isSetter;

  MethodDeclaration(this.name, this.parameterList, this.body, this.returnType,
      this.isGetter, this.isSetter);

  static MethodDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.MethodDeclaration)) {
      return MethodDeclaration(
          ast['name'],
          FormalParameterList.fromAst(ast['parameters']),
          AstRuntimeNodeParser.fromAst(ast['body']) as FunctionBody?,
          TypeName.fromAst(ast['returnType']),
          ast['isGetter'],
          ast['isSetter']);
    }
    logDebug(_tag, 'Can not parse ast to MethodDeclaration');
    return null;
  }
}

/// A function expression.
///
///    functionExpression ::=
///        [TypeParameterList]? [FormalParameterList] [FunctionBody]
///
class FunctionExpression implements AstRuntimeNode {
  FormalParameterList? parameterList;
  FunctionBody? body;

  FunctionExpression(this.parameterList, this.body);

  static FunctionExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.FunctionExpression)) {
      return FunctionExpression(FormalParameterList.fromAst(ast['parameters']),
          AstRuntimeNodeParser.fromAst(ast['body']) as FunctionBody?);
    }
    logDebug(_tag, 'Can not parse ast to FunctionExpression');
    return null;
  }
}

/// A top-level function declaration.
///
///    functionDeclaration ::=
///        'external' functionSignature
///      | functionSignature [FunctionBody]
///
///    functionSignature ::=
///        [Type]? ('get' | 'set')? [SimpleIdentifier] [FormalParameterList]
///
class FunctionDeclaration implements AstRuntimeNode {
  String? name;
  FunctionExpression? expression;
  TypeName? returnType;

  FunctionDeclaration(this.name, this.expression, this.returnType);

  static FunctionDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.FunctionDeclaration)) {
      return FunctionDeclaration(
        ast['name'],
        FunctionExpression.fromAst(ast['expression']),
        TypeName.fromAst(ast['returnType']),
      );
    }
    logDebug(_tag, 'Can not parse ast to FunctionDeclaration');
    return null;
  }
}

/// The invocation of either a function or a method.
///
/// Invocations of functions resulting from evaluating an expression are
/// represented by [FunctionExpressionInvocation] nodes. Invocations of getters
/// and setters are represented by either [PrefixedIdentifier] or
/// [PropertyAccess] nodes.
///
///    methodInvocation ::=
///        ([AstNode] '.')? [SimpleIdentifier] [TypeArgumentList]? [ArgumentList]
///
class MethodInvocation implements AstRuntimeNode {
  AstRuntimeNode? callee;
  List<AstRuntimeNode> argumentList;
  bool isNullAware;

  MethodInvocation(this.callee, this.argumentList, this.isNullAware);

  static MethodInvocation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.MethodInvocation)) {
      return MethodInvocation(AstRuntimeNodeParser.fromAst(ast['callee']),
          _parseArgumentList(ast['argumentList']), ast['isNullAware'] ?? false);
    }
    logDebug(_tag, 'Can not parse ast to MethodInvocation');
    return null;
  }
}

/// An expression that has a name associated with it. They are used in method
/// invocations when there are named parameters.
///
///    namedExpression ::=
///        [Label] [AstNode]
///
class NamedExpression implements AstRuntimeNode {
  String? name;
  AstRuntimeNode? expression;

  NamedExpression(this.name, this.expression);

  static NamedExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.NamedExpression)) {
      return NamedExpression(
        ast['name'],
        AstRuntimeNodeParser.fromAst(ast['expression']),
      );
    }
    logDebug(_tag, 'Can not parse ast to NamedExpression');
    return null;
  }
}

/// A prefix unary expression.
///
///    prefixExpression ::=
///        [Token] [AstNode]
///
class PrefixExpression implements AstRuntimeNode {
  ///操作的变量名称
  AstRuntimeNode? argument;

  ///操作符
  String? operator;

  ///是否操作符前置
  bool? prefix;

  PrefixExpression(this.argument, this.operator, this.prefix);

  static PrefixExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.PrefixExpression)) {
      return PrefixExpression(AstRuntimeNodeParser.fromAst(ast['argument']),
          ast['operator'], ast['prefix'] as bool?);
    }
    logDebug(_tag, 'Can not parse ast to PrefixExpression');
    return null;
  }
}

/// An identifier that has an initial value associated with it.
///
/// Instances of this class are always children of the class
/// [VariableDeclarationList].
///
///    variableDeclaration ::=
///        [SimpleIdentifier] ('=' [AstNode])?
///
class VariableDeclaration implements AstRuntimeNode {
  String? name;
  AstRuntimeNode? init;

  VariableDeclaration(this.name, this.init);

  static VariableDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.VariableDeclaration)) {
      return VariableDeclaration(
          ast['name'], AstRuntimeNodeParser.fromAst(ast['init']));
    }
    logDebug(_tag, 'Can not parse ast to VariableDeclaration');
    return null;
  }
}

/// The declaration of one or more variables of the same type.
///
///    variableDeclarationList ::=
///        finalConstVarOrType [VariableDeclaration] (',' [VariableDeclaration])*
///
///    finalConstVarOrType ::=
///      'final' 'late'? [TypeAnnotation]?
///      | 'const' [TypeAnnotation]?
///      | 'var'
///      | 'late'? [TypeAnnotation]
///
class VariableDeclarationList implements AstRuntimeNode {
  String? typeAnnotation;
  List<VariableDeclaration> declarationList;

  VariableDeclarationList(this.typeAnnotation, this.declarationList);

  static VariableDeclarationList? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.VariableDeclarationList)) {
      var astDeclarations = ast['declarations'] as List?;
      var declarations = astDeclarations
              ?.map<VariableDeclaration?>((e) => VariableDeclaration.fromAst(e))
              .where((element) => element != null)
              .map<VariableDeclaration>((e) => e!)
              .toList() ??
          [];
      return VariableDeclarationList(
          TypeName.fromAst(ast['typeAnnotation'])?.name, declarations);
    }
    logDebug(_tag, 'Can not parse ast to VariableDeclarationList');
    return null;
  }
}

/// The declaration of one or more fields of the same type.
///
///    fieldDeclaration ::=
///        'static' 'const' <type>? <staticFinalDeclarationList>
///      | 'static' 'final' <type>? <staticFinalDeclarationList>
///      | 'static' 'late' 'final' <type>? <initializedIdentifierList>
///      | 'static' 'late'? <varOrType> <initializedIdentifierList>
///      | 'covariant' 'late'? <varOrType> <initializedIdentifierList>
///      | 'late'? 'final' <type>? <initializedIdentifierList>
///      | 'late'? <varOrType> <initializedIdentifierList>
///      | 'external' ('static'? <finalVarOrType> | 'covariant' <varOrType>)
///            <identifierList>
///      | 'abstract' (<finalVarOrType> | 'covariant' <varOrType>)
///            <identifierList>
///
/// (Note: there is no <fieldDeclaration> production in the grammar; this is a
/// subset of the grammar production <declaration>, which encompasses everything
/// that can appear inside a class declaration except methods).
///
/// Prior to the 'extension-methods' experiment, these nodes were always
/// children of a class declaration. When the experiment is enabled, these nodes
/// can also be children of an extension declaration.
///
class FieldDeclaration implements AstRuntimeNode {
  VariableDeclarationList? fields;
  List<Annotation> metadata;

  FieldDeclaration(this.fields, this.metadata);

  static FieldDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.FieldDeclaration)) {
      var astMetadata = ast['metadata'] as List?;
      var metadata = astMetadata
              ?.map<Annotation?>((e) => Annotation.fromAst(e))
              .where((element) => element != null)
              .map<Annotation>((e) => e!)
              .toList() ??
          [];

      return FieldDeclaration(
          VariableDeclarationList.fromAst(ast['fields']), metadata);
    }
    logDebug(_tag, 'Can not parse ast to FieldDeclaration');
    return null;
  }
}

/// A binary (infix) expression.
///
///    binaryExpression ::=
///        [Expression] [Token] [Expression]
///
class BinaryExpression implements AstRuntimeNode {
  ///运算符
  /// * +
  /// * -
  /// * *
  /// * /
  /// * <
  /// * >
  /// * <=
  /// * >=
  /// * ==
  /// * &&
  /// * ||
  /// * %
  /// * <<
  /// * |
  /// * &
  /// * >>
  ///
  String? operator;

  ///左操作表达式
  AstRuntimeNode? left;

  ///右操作表达式
  AstRuntimeNode? right;

  BinaryExpression(this.operator, this.left, this.right);

  static BinaryExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.BinaryExpression)) {
      return BinaryExpression(
          ast['operator'],
          AstRuntimeNodeParser.fromAst(ast['left']),
          AstRuntimeNodeParser.fromAst(ast['right']));
    }
    logDebug(_tag, 'Can not parse ast to BinaryExpression');
    return null;
  }
}

/// An assignment expression.
///
///    assignmentExpression ::=
///        [AstNode] operator [AstNode]
///
class AssignmentExpression implements AstRuntimeNode {
  String? operator;
  AstRuntimeNode? left;
  AstRuntimeNode? right;

  AssignmentExpression(this.operator, this.left, this.right);

  static AssignmentExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.AssignmentExpression)) {
      return AssignmentExpression(
          ast['operator'],
          AstRuntimeNodeParser.fromAst(ast['left']),
          AstRuntimeNodeParser.fromAst(ast['right']));
    }
    logDebug(_tag, 'Can not parse ast to AssignmentExpression');
    return null;
  }
}

/// An await expression.
///
///    awaitExpression ::=
///        'await' [Expression]
///
class AwaitExpression implements AstRuntimeNode {
  MethodInvocation? expression;

  AwaitExpression(this.expression);

  static AwaitExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.AwaitExpression)) {
      return AwaitExpression(
        MethodInvocation.fromAst(ast['expression']),
      );
    }
    logDebug(_tag, 'Can not parse ast to AwaitExpression');
    return null;
  }
}

/// The declaration of a class.
///
///    classDeclaration ::=
///        'abstract'? 'class' [SimpleIdentifier] [TypeParameterList]?
///        ([implementsClause] [WithClause]?)?
///        [ImplementsClause]?
///        '{' [ClassMember]* '}'
///
class ClassDeclaration implements AstRuntimeNode {
  String? name;
  String? superClause;
  ImplementsClause? implementsClause;
  WithClause? mixinClause;
  List<AstRuntimeNode> body;

  ClassDeclaration(
    this.name,
    this.superClause,
    this.implementsClause,
    this.mixinClause,
    this.body,
  );

  static ClassDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ClassDeclaration)) {
      var astBody = ast['body'] as List;
      var bodies = <AstRuntimeNode>[];
      for (var arg in astBody) {
        var expression = AstRuntimeNodeParser.fromAst(arg);
        if (expression != null) {
          bodies.add(expression);
        }
      }
      return ClassDeclaration(
        ast['name'],
        TypeName.fromAst(ast['superClause'])?.name,
        ImplementsClause.fromAst(ast['implementsClause']),
        WithClause.fromAst(ast['withClause']),
        bodies,
      );
    }
    logDebug(_tag, 'Can not parse ast to ClassDeclaration');
    return null;
  }
}

/// The 'implements' clause in an class declaration.
///
///    implementsClause ::=
///        'implements' [TypeName] (',' [TypeName])*
///
class ImplementsClause implements AstRuntimeNode {
  List<String?> implements;

  ImplementsClause(this.implements);

  static ImplementsClause? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ImplementsClause)) {
      var astImplements = ast['implements'] as List;
      var implements = <String?>[];
      for (var typeName in astImplements) {
        implements.add(typeName['name']);
      }
      return ImplementsClause(implements);
    }
//    logDebug(_tag, 'Can not parse ast to ImplementsClause');
    return null;
  }
}

/// The with clause in a class declaration.
///
///    withClause ::=
///        'with' [TypeName] (',' [TypeName])*
///
class WithClause implements AstRuntimeNode {
  List<String?> mixinTypes;
  WithClause(this.mixinTypes);

  static WithClause? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.WithClause)) {
      var astMixin = ast['mixinTypes'] as List;
      var mixinTypes = <String?>[];
      for (var typeName in astMixin) {
        mixinTypes.add(typeName['name']);
      }
      return WithClause(mixinTypes);
    }
//    logDebug(_tag, 'Can not parse ast to WithClause');
    return null;
  }
}

/// An if statement.
///
///    ifStatement ::=
///        'if' '(' [Expression] ')' [Statement] ('else' [Statement])?
///
class IfStatement implements AstRuntimeNode {
  ///判断条件
  AstRuntimeNode? condition;

  ///true 执行代码块
  AstRuntimeNode? consequent;

  ///false 执行代码块
  AstRuntimeNode? alternate;

  IfStatement(this.condition, this.consequent, this.alternate);

  static IfStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.IfStatement)) {
      return IfStatement(
          AstRuntimeNodeParser.fromAst(ast['condition']),
          AstRuntimeNodeParser.fromAst(ast['consequent']),
          AstRuntimeNodeParser.fromAst(ast['alternate']));
    }
    logDebug(_tag, 'Can not parse ast to IfStatement');
    return null;
  }
}

/// A for or for-each statement.
///
///    forStatement ::=
///        'for' '(' forLoopParts ')' [Statement]
///
///    forLoopParts ::=
///       [VariableDeclaration] ';' [AstNode]? ';' expressionList?
///     | [AstNode]? ';' [AstNode]? ';' expressionList?
///     | [DeclaredIdentifier] 'in' [AstNode]
///     | [SimpleIdentifier] 'in' [AstNode]
///
/// This is the class that is used to represent a for loop when either the
/// 'control-flow-collections' or 'spread-collections' experiments are enabled.
/// If neither of those experiments are enabled, then either `ForStatement` or
/// `ForEachStatement` will be used.
///
class ForStatement implements AstRuntimeNode {
  ForLoopParts? forLoopParts;
  Block? body;

  ForStatement(this.forLoopParts, this.body);

  static ForStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ForStatement)) {
      return ForStatement(ForLoopParts.fromAst(ast['forLoopParts']),
          Block.fromAst(ast['body']));
    }
    logDebug(_tag, 'Can not parse ast to ForStatement');
    return null;
  }
}

/// The parts of a for or for-each loop that control the iteration.
///
///   forLoopParts ::=
///       [VariableDeclaration] ';' [AstNode]? ';' expressionList?
///     | [Expression]? ';' [AstNode]? ';' expressionList?
///     | [DeclaredIdentifier] 'in' [AstNode]
///     | [SimpleIdentifier] 'in' [AstNode]
///
///   expressionList ::=
///       [AstNode] (',' [AstNode])*
///
class ForLoopParts implements AstRuntimeNode {
  static const String forPartsWithDeclarations = 'ForPartsWithDeclarations';
  static const String forPartsWithExpression = 'ForPartsWithExpression';
  static const String forEachPartsWithDeclaration =
      'ForEachPartsWithDeclaration';

  String type;

  ///初始化定义的值
  VariableDeclarationList? variableList;

  ///初始化赋值的值
  AssignmentExpression? initialization;

  ///循环判断条件
  BinaryExpression? condition;

  ///循环步进值
  AstRuntimeNode? updater;

  //for...in... 遍历迭代的数据集合变量名称
  String? iterable;

  //for...in... 遍历迭代值
  String? loopVariable;

  ForLoopParts(this.type,
      {this.variableList,
      this.initialization,
      this.condition,
      this.updater,
      this.iterable,
      this.loopVariable});

  static ForLoopParts? fromAst(Map? ast) {
    if (ast != null) {
      switch (ast['type']) {
        case forPartsWithDeclarations:
          var updaters = ast['updaters'] as List;
          return ForLoopParts(
            forPartsWithDeclarations,
            variableList: VariableDeclarationList.fromAst(ast['variableList']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater: updaters.isNotEmpty
                ? AstRuntimeNodeParser.fromAst(updaters[0])
                : null,
          );

        case forPartsWithExpression:
          var updaters = ast['updaters'] as List;

          return ForLoopParts(
            forPartsWithExpression,
            initialization: AssignmentExpression.fromAst(ast['initialization']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater: updaters.isNotEmpty
                ? AstRuntimeNodeParser.fromAst(updaters[0])
                : null,
          );

        case forEachPartsWithDeclaration:
          return ForLoopParts(
            forEachPartsWithDeclaration,
            iterable: SimpleIdentifier.fromAst(ast['iterable'])?.name,
            loopVariable:
                SimpleIdentifier.fromAst(ast['loopVariable']['id'])?.name,
          );
      }
    }
    logDebug(_tag, 'Can not parse ast to ForLoopParts');
    return null;
  }
}

/// A switch statement.
///
///    switchStatement ::=
///        'switch' '(' [AstNode] ')' '{' [SwitchCase]* [SwitchDefault]? '}'
///
class SwitchStatement implements AstRuntimeNode {
  AstRuntimeNode? checkValue;
  List<SwitchCase> body;

  SwitchStatement(this.checkValue, this.body);

  static SwitchStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.SwitchStatement)) {
      var list = ast['body'] as List?;
      var caseList = list
              ?.map<SwitchCase?>((e) => SwitchCase.fromAst(e))
              .where((element) => element != null)
              .map((e) => e!)
              .toList() ??
          [];

      return SwitchStatement(
        AstRuntimeNodeParser.fromAst(ast['checkValue']),
        caseList,
      );
    }
    logDebug(_tag, 'Can not parse ast to SwitchStatement');
    return null;
  }
}

/// A case in a switch statement.
///
///    switchCase ::=
///        [SimpleIdentifier]* 'case' [AstNode] ':' [Statement]*
///
class SwitchCase implements AstRuntimeNode {
  AstRuntimeNode? condition;
  List<AstRuntimeNode?> statements;
  bool isDefault;

  SwitchCase(this.condition, this.statements, this.isDefault);

  static SwitchCase? fromAst(Map? ast) {
    if (ast != null) {
      var statements = <AstRuntimeNode?>[];
      var list = ast['statements'] as List?;
      list?.forEach((s) {
        statements.add(AstRuntimeNodeParser.fromAst(s));
      });

      if (ast['type'] == astNodeNameValue(AstRuntimeNodeName.SwitchCase)) {
        return SwitchCase(
            AstRuntimeNodeParser.fromAst(ast['condition']), statements, false);
      } else if (ast['type'] ==
          astNodeNameValue(AstRuntimeNodeName.SwitchDefault)) {
        return SwitchCase(
          null,
          statements,
          true,
        );
      } else {
        logDebug(_tag, 'Can not parse ast to SwitchCase');
        return null;
      }
    }
    logDebug(_tag, 'Can not parse ast to SwitchCase');
    return null;
  }
}

/// A return statement.
///
///    returnStatement ::=
///        'return' [AstNode]? ';'
///
class ReturnStatement implements AstRuntimeNode {
  AstRuntimeNode? argument;

  ReturnStatement(this.argument);

  static ReturnStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ReturnStatement)) {
      return ReturnStatement(AstRuntimeNodeParser.fromAst(ast['argument']));
    }
    logDebug(_tag, 'Can not parse ast to ReturnStatement');
    return null;
  }
}

/// The access of a property of an object.
///
/// Note, however, that accesses to properties of objects can also be
/// represented as [PrefixedIdentifier] nodes in cases where the target is also
/// a simple identifier.
///
///    propertyAccess ::=
///        [AstNode] '.' [SimpleIdentifier]
///
class PropertyAccess implements AstRuntimeNode {
  String? name;
  AstRuntimeNode? expression;
  bool isNullAware;

  PropertyAccess(this.name, this.expression, this.isNullAware);

  static PropertyAccess? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.PropertyAccess)) {
      return PropertyAccess(
          ast['name'],
          AstRuntimeNodeParser.fromAst(ast['expression']),
          ast['isNullAware'] ?? false);
    }
    logDebug(_tag, 'Can not parse ast to PropertyAccess');
    return null;
  }
}

/// An index expression.
///
///    indexExpression ::=
///        [AstNode] '[' [AstNode] ']'
///
class IndexExpression implements AstRuntimeNode {
  AstRuntimeNode? target;
  AstRuntimeNode? index;
  bool? isNullAware;

  IndexExpression(this.target, this.index, this.isNullAware);

  static IndexExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.IndexExpression)) {
      return IndexExpression(AstRuntimeNodeParser.fromAst(ast['target']),
          AstRuntimeNodeParser.fromAst(ast['index']), ast['isNullAware']);
    }
    logDebug(_tag, 'Can not parse ast to IndexExpression');
    return null;
  }
}

class Program implements AstRuntimeNode {
  AstRuntimeNode? body;
  List<String>? referenceAstIds;
  String? astId;
  String? hash;
  //Ast类型
  String? annotationType;
  Program(this.body, this.referenceAstIds, this.astId, this.hash,
      this.annotationType);

  static Program? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.Program)) {
      var astBody = ast['body'];
      var ids = (ast['referenceAstIds'] as List?)?.cast<String>();

      return Program(AstRuntimeNodeParser.fromAst(astBody), ids, ast['astId'],
          ast['hash'], ast['annotationType']);
    }
    logDebug(_tag, 'Can not parse ast to Program');
    return null;
  }
}

/// The invocation of a function resulting from evaluating an expression.
///
/// Invocations of methods and other forms of functions are represented by
/// [MethodInvocation] nodes. Invocations of getters and setters are represented
/// by either [PrefixedIdentifier] or [PropertyAccess] nodes.
///
///    functionExpressionInvocation ::=
///        [Expression] [TypeArgumentList]? [ArgumentList]
///
class FunctionExpressionInvocation implements AstRuntimeNode {
  List<AstRuntimeNode?> argumentList;
  AstRuntimeNode? function;

  FunctionExpressionInvocation(this.function, this.argumentList);

  static FunctionExpressionInvocation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.FunctionExpressionInvocation)) {
      return FunctionExpressionInvocation(
          AstRuntimeNodeParser.fromAst(ast['function']),
          _parseArgumentList(ast['argumentList']));
    }
    logDebug(_tag, 'Can not parse ast to FunctionExpressionInvocation');
    return null;
  }
}

/// An as expression.
///
///    asExpression ::=
///        [AstNode] 'as' [TypeAnnotation]
///
class AsExpression implements AstRuntimeNode {
  AstRuntimeNode? expression;
  TypeName? asType;

  AsExpression(this.expression, this.asType);

  static AsExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.AsExpression)) {
      return AsExpression(
        AstRuntimeNodeParser.fromAst(ast['expression']),
        TypeName.fromAst(ast['asType']),
      );
    }
    logDebug(_tag, 'Can not parse ast to AsExpression');
    return null;
  }
}

/// An is expression.
///
///    isExpression ::=
///        [Expression] 'is' '!'? [TypeAnnotation]
///
class IsExpression implements AstRuntimeNode {
  bool notOperator;
  AstRuntimeNode? expression;
  String? typeAnnotation;

  IsExpression(this.notOperator, this.expression, this.typeAnnotation);

  static IsExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.IsExpression)) {
      return IsExpression(
          ast['not'] ?? false,
          AstRuntimeNodeParser.fromAst(ast['expression']),
          ast['typeAnnotation']);
    }
    return null;
  }
}

class FHAstAnnotation implements AstRuntimeNode {
  String? astId;
  String? name;

  ///Ast 注解类型
  ///* FHClassAnnotation
  ///* FHConstantAnnotation
  ///* FHFunctionAnnotation
  ///* FHDataModelAnnotation
  String? type;
  String? filePath;
  String? hash;
  String? annotationType;

  FHAstAnnotation({
    this.name,
    this.astId,
    this.type,
    this.filePath,
    this.hash,
    this.annotationType,
  });

  static FHAstAnnotation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.FHClassAnnotation)) {
      return FHAstAnnotation(
          name: ast['name'],
          astId: ast['astId'],
          type: ast['type'],
          filePath: ast['filePath'],
          hash: ast['hash'],
          annotationType: ast['annotationType']);
    }
    logDebug(_tag, 'Can not parse ast to FHAstAnnotation');
    return null;
  }
}

/// A conditional expression.
///
///    conditionalExpression ::=
///        [Expression] '?' [Expression] ':' [Expression]
///
class ConditionalExpression implements AstRuntimeNode {
  AstRuntimeNode? condition;
  AstRuntimeNode? thenExpression;
  AstRuntimeNode? elseExpression;

  ConditionalExpression(
      {this.condition, this.thenExpression, this.elseExpression});

  static ConditionalExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.ConditionalExpression)) {
      return ConditionalExpression(
          condition: AstRuntimeNodeParser.fromAst(ast['condition']),
          thenExpression: AstRuntimeNodeParser.fromAst(ast['then']),
          elseExpression: AstRuntimeNodeParser.fromAst(ast['else']));
    }
    logDebug(_tag, 'Can not parse ast to ConditionalExpression');
    return null;
  }
}

/// A super expression.
///
///    superExpression ::=
///        'super'
///
class SuperExpression implements AstRuntimeNode {
  String? name;
  SuperExpression(this.name);

  static SuperExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.SuperExpression)) {
      return SuperExpression(ast['name']);
    }
    logDebug(_tag, 'Can not parse ast to SuperExpression');
    return null;
  }
}

/// The invocation of a superclass' constructor from within a constructor's
/// initialization list.
///
///    superInvocation ::=
///        'super' ('.' [SimpleIdentifier])? [ArgumentList]
///
class SuperConstructorInvocation implements AstRuntimeNode {
  List<AstRuntimeNode?>? arguments;

  SuperConstructorInvocation({this.arguments});

  static SuperConstructorInvocation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.SuperConstructorInvocation)) {
      return SuperConstructorInvocation(
        arguments: _parseArgumentList(ast['arguments']),
      );
    }
    logDebug(_tag, 'Can not parse ast to SuperConstructorInvocation');
    return null;
  }
}

/// A this expression.
///
///    thisExpression ::=
///        'this'
///
class ThisExpression implements AstRuntimeNode {
  ThisExpression();

  static ThisExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ThisExpression)) {
      return ThisExpression();
    }
    logDebug(_tag, 'Can not parse ast to ThisExpression');
    return null;
  }
}

/// A break statement.
///
///    breakStatement ::=
///        'break' [SimpleIdentifier]? ';'
///
class BreakStatement implements AstRuntimeNode {
  BreakStatement();

  static BreakStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.BreakStatement)) {
      return BreakStatement();
    }
    logDebug(_tag, 'Can not parse ast to BreakStatement');
    return null;
  }
}

/// A constructor declaration.
///
///    constructorDeclaration ::=
///        constructorSignature [FunctionBody]?
///      | constructorName formalParameterList ':' 'this' ('.' [SimpleIdentifier])? arguments
///
///    constructorSignature ::=
///        'external'? constructorName formalParameterList initializerList?
///      | 'external'? 'factory' factoryName formalParameterList initializerList?
///      | 'external'? 'const'  constructorName formalParameterList initializerList?
///
///    constructorName ::=
///        [SimpleIdentifier] ('.' [SimpleIdentifier])?
///
///    factoryName ::=
///        [Identifier] ('.' [SimpleIdentifier])?
///
///    initializerList ::=
///        ':' [ConstructorInitializer] (',' [ConstructorInitializer])*
///
class ConstructorDeclaration implements AstRuntimeNode {
  FormalParameterList? parameters;
  List<AstRuntimeNode>? initializerList;
  BlockFunctionBody? body;
  AstRuntimeNode? returnType;

  ConstructorDeclaration(
    this.parameters,
    this.initializerList,
    this.body,
    this.returnType,
  );

  static ConstructorDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.ConstructorDeclaration)) {
      var initializer = ast['initializer'] as List?;
      return ConstructorDeclaration(
          FormalParameterList.fromAst(ast['parameters']),
          initializer
              ?.map<AstRuntimeNode?>((e) {
                //尝试解析ConstructorFieldInitializer
                AstRuntimeNode? r = ConstructorFieldInitializer.fromAst(e);
                if (r == null) {
                  //尝试解析SuperConstructorInvocation
                  r = SuperConstructorInvocation.fromAst(e);
                }
                return r;
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList(),
          BlockFunctionBody.fromAst(ast['body']),
          AstRuntimeNodeParser.fromAst(ast['returnType']));
    }
    logDebug(_tag, 'Can not parse ast to ConstructorDeclaration');
    return null;
  }
}

/// The initialization of a field within a constructor's initialization list.
///
///    fieldInitializer ::=
///        ('this' '.')? [SimpleIdentifier] '=' [Expression]
///
class ConstructorFieldInitializer implements AstRuntimeNode {
  String? fieldName;
  AstRuntimeNode? fieldValue;
  ConstructorFieldInitializer(this.fieldName, this.fieldValue);

  static ConstructorFieldInitializer? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.ConstructorFieldInitializer)) {
      return ConstructorFieldInitializer(
          ast['fieldName'], AstRuntimeNodeParser.fromAst(ast['fieldValue']));
    }
//    logDebug(_tag, 'Can not parse ast to ConstructorFieldInitializer');
    return null;
  }
}

/// An instance creation expression.
///
///    newExpression ::=
///        ('new' | 'const')? [TypeName] ('.' [SimpleIdentifier])? [ArgumentList]
///
class InstanceCreationExpression implements AstRuntimeNode {
  ConstructorName? callee;
  List<AstRuntimeNode> arguments;

  InstanceCreationExpression(this.callee, this.arguments);

  static InstanceCreationExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.InstanceCreationExpression)) {
      return InstanceCreationExpression(
        ConstructorName.fromAst(ast['callee']),
        _parseArgumentList(ast['arguments']),
      );
    }
    logDebug(_tag, 'Can not parse ast to InstanceCreationExpression');
    return null;
  }
}

/// The name of a constructor.
///
///    constructorName ::=
///        type ('.' name)?
///
class ConstructorName implements AstRuntimeNode {
  String? name;
  TypeName? typeName;

  ConstructorName(this.name, this.typeName);

  static ConstructorName? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstRuntimeNodeName.ConstructorName)) {
      return ConstructorName(ast['name'], TypeName.fromAst(ast['typeName']));
    }
    logDebug(_tag, 'Can not parse ast to ConstructorName');
    return null;
  }
}

/// An expression used as a statement.
///
///    expressionStatement ::=
///        [Expression]? ';'
///
class ExpressionStatement implements AstRuntimeNode {
  AstRuntimeNode? expression;

  ExpressionStatement(this.expression);

  static ExpressionStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] ==
            astNodeNameValue(AstRuntimeNodeName.ExpressionStatement)) {
      return ExpressionStatement(
          AstRuntimeNodeParser.fromAst(ast['expression']));
    }
    logDebug(_tag, 'Can not parse ast to ExpressionStatement');
    return null;
  }
}

///解析ArgumentList 字段
List<AstRuntimeNode> _parseArgumentList(Map ast) {
  var astArguments = ast['argumentList'] as List;
  var arguments = <AstRuntimeNode>[];
  for (var arg in astArguments) {
    var node = AstRuntimeNodeParser.fromAst(arg);
    if (node != null) {
      arguments.add(node);
    }
  }
  return arguments;
}
