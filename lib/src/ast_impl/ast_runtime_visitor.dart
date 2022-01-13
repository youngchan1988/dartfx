import 'dart:convert';
import 'dart:io';
import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/visitor.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

///
/// Author: YoungChan
/// Date: 2022-01-10 16:53:23
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-10 16:53:23
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

class AstRuntimeVisitor implements AstVisitor<Map> {
  ///需要引用的Ast
  List<String> _referenceAstIds = [];

  ///import 依赖路径
  List<String> _importPaths = [];

  AstRuntimeVisitor();

  bool? _isDebug = false;

  AstRuntimeVisitor openDebug(bool? debug) {
    _isDebug = debug;
    return this;
  }

  Map _buildBlock(List body) => {"type": "Block", "body": body};

  Map _buildIfStatement(Map? testExpression, Map? consequent, Map? alternate) =>
      {
        "type": "IfStatement",
        "condition": testExpression,
        "consequent": consequent,
        "alternate": alternate
      };
  Map _buildExpressionStatement(Map? expression) =>
      {"type": "ExpressionStatement", "expression": expression};

  // Map _buildVariableDeclarationStatement(Map expression) =>
  //     {"type": "VariableDeclarationStatement", "expression": expression};

  Map _buildPrefixExpression(String operator, bool isPrefix, Map? argument) => {
        "type": "PrefixExpression",
        "operator": operator,
        "prefix": isPrefix,
        "argument": argument
      };

  Map _buildSimpleIdentifier(String name) =>
      {"type": "SimpleIdentifier", "name": name};

  Map _buildDoubleLiteral(double value) =>
      {"type": "DoubleLiteral", "value": value};

  Map _buildIntegerLiteral(int? value) =>
      {"type": "IntegerLiteral", "value": value};

  Map _buildStringLiteral(String value) =>
      {"type": "StringLiteral", "value": value};

  Map _buildBooleanLiteral(bool value) =>
      {"type": "BooleanLiteral", "value": value};

  Map _buildBinaryExpression(Map? left, Map? right, String lexeme) => {
        "type": "BinaryExpression",
        "operator": lexeme,
        "left": left,
        "right": right
      };

  Map _buildIndexExpression(Map? target, Map? index, bool isNullAware) => {
        "type": "IndexExpression",
        "target": target,
        "index": index,
        "isNullAware": isNullAware,
      };

  Map _buildMethodInvocation(Map? callee, Map? typeArguments, Map? argumentList,
          bool isNulAware) =>
      {
        "type": "MethodInvocation",
        "callee": callee,
        "typeArguments": typeArguments,
        "argumentList": argumentList,
        //是否可空
        "isNullAware": isNulAware,
      };
  Map _buildTypeArgumentList(List<Map> arguments) =>
      {"type": "TypeArgumentList", "arguments": arguments};

  Map _buildAssignmentExpression(Map? left, Map? right, String lexeme) => {
        "type": "AssignmentExpression",
        "left": left,
        "operator": lexeme,
        "right": right,
      };

  Map _buildAwaitExpression(Map? expression) => {
        "type": "AwaitExpression",
        "expression": expression,
      };

  Map _buildBreakStatement() => {"type": "BreakStatement"};

  Map _buildClassDeclaration(
          String name,
          Map? superClause,
          Map? implementsClause,
          Map? withClause,
          List<Map> metadata,
          List<Map> body,
          {String? hash}) =>
      {
        "type": "ClassDeclaration",
        "name": name,
        "superClause": superClause,
        "implementsClause": implementsClause,
        "withClause": withClause,
        'metadata': metadata,
        "body": body,
        'hash': hash,
      };

  Map _buildClassTypeAlias(Map? id, Map? implementsClause) => {
        "type": "ClassTypeAlias",
        "id": id,
        "implementsClause": implementsClause,
      };

  Map _buildCompilationUnit(Map body,
          {String? astId,
          String? hash,
          String? annotationType,
          List<String>? refAstIds}) =>
      {
        "type": "Program",
        "body": body,
        'astId': astId,
        'hash': hash,
        'annotationType': annotationType,
        'referenceAstIds': refAstIds,
      };

  Map _buildConstructorDeclaration(Map? id, Map? parameters,
          List<Map> initializer, Map? body, Map? returnType) =>
      {
        "type": "ConstructorDeclaration",
        "id": id,
        "parameters": parameters,
        "initializer": initializer,
        "body": body,
        "returnType": returnType,
      };

  Map _buildConstructorFieldInitializer(String fieldName, Map? expression) => {
        "type": "ConstructorFieldInitializer",
        "fieldName": fieldName,
        "fieldValue": expression
      };

  Map _buildDeclaredIdentifier(Map? id, Map? typeAnnotation, String keyword) =>
      {
        "type": "DeclaredIdentifier",
        "id": id,
        "typeAnnotation": typeAnnotation,
        "keyword": keyword,
      };

  Map _buildDefaultFormalParameter(
          String name,
          Map? defaultValue,
          bool isNamed,
          bool isOptional,
          bool isPositional,
          bool isOptionalNamed,
          bool isOptionalPositional) =>
      {
        "type": "DefaultFormalParameter",
        "name": name,
        "defaultValue": defaultValue,
        "isNamed": isNamed,
        "isOptional": isOptional,
        "isPositional": isPositional,
        "isOptionalNamed": isOptionalNamed,
        "isOptionalPositional": isOptionalPositional,
      };

  Map _buildFieldDeclaration(Map? fields, List<Map> metadata) => {
        "type": "FieldDeclaration",
        "fields": fields,
        'metadata': metadata,
      };

  Map _buildFieldFormalParameter(
          String name,
          Map? typeParameters,
          Map? parameters,
          bool thisKeyword,
          bool isNamed,
          bool isOptional,
          bool isPositional,
          bool isOptionalNamed,
          bool isOptionalPositional) =>
      {
        "type": "FieldFormalParameter",
        "name": name,
        "typeParameters": typeParameters,
        "parameters": parameters,
        "thisKeyword": thisKeyword,
        "isNamed": isNamed,
        "isOptional": isOptional,
        "isPositional": isPositional,
        "isOptionalNamed": isOptionalNamed,
        "isOptionalPositional": isOptionalPositional,
      };

  Map _buildForEachPartsWithDeclaration(Map? loopVariable, Map? iterable) => {
        "type": "ForEachPartsWithDeclaration",
        "loopVariable": loopVariable,
        "iterable": iterable,
      };

  Map _buildForEachPartsWithIdentifier(Map? id, Map? iterable) => {
        "type": "ForEachPartsWithIdentifier",
        "id": id,
        "iterable": iterable,
      };

  Map _buildForPartsWithDeclarations(
          Map? variableList, Map? condition, List<Map> updaters) =>
      {
        "type": "ForPartsWithDeclarations",
        "variableList": variableList,
        "condition": condition,
        "updaters": updaters,
      };

  Map _buildForPartsWithExpression(
          Map? initialization, Map? condition, List<Map> updaters) =>
      {
        "type": "ForPartsWithExpression",
        "initialization": initialization,
        "condition": condition,
        "updaters": updaters,
      };

  Map _buildForStatement(Map? forLoopParts, Map? body) => {
        "type": "ForStatement",
        "forLoopParts": forLoopParts,
        "body": body,
      };

  Map _buildFunctionDeclaration(String name, Map? expression, Map? returnType,
          {String? hash}) =>
      {
        "type": "FunctionDeclaration",
        "name": name,
        "expression": expression,
        "returnType": returnType,
        'hash': hash,
      };

  Map _buildFunctionExpression(Map? params, Map? body) => {
        "type": "FunctionExpression",
        "parameters": params,
        "body": body,
      };

  Map _buildFunctionTypedFormalParameter(
          Map? id, Map? returnType, Map? params) =>
      {
        "type": "FunctionTypedFormalParameter",
        "id": id,
        "params": params,
        "returnType": returnType,
      };

  Map _buildInstanceCreationExpression(
          Map? constructorName, Map? argumentsList) =>
      {
        "type": "InstanceCreationExpression",
        "callee": constructorName,
        "arguments": argumentsList,
      };

  Map _buildInterpolationExpression(Map? value) => {
        "type": "InterpolationExpression",
        "value": value,
      };

  Map _buildInterpolationString(String value) => {
        "type": "InterpolationString",
        "value": value,
      };

  Map _buildListLiteral(List<Map> elements) => {
        "type": "ListLiteral",
        "elements": elements,
      };

  Map _buildMapLiteralEntry(Map? key, Map? value) => {
        "type": "MapLiteralEntry",
        "key": key,
        "value": value,
      };

  Map _buildMethodDeclaration(String name, Map? parameters, Map? typeParameters,
          Map? body, Map? returnType,
          {bool isGetter = false, bool isSetter = false}) =>
      {
        "type": "MethodDeclaration",
        "name": name,
        "parameters": parameters,
        "typeParameters": typeParameters,
        "body": body,
        "returnType": returnType,
        'isGetter': isGetter,
        'isSetter': isSetter,
      };

  Map _buildNamedExpression(String name, Map? expression) => {
        "type": "NamedExpression",
        "name": name,
        "expression": expression,
      };

  Map _buildPrefixedIdentifier(String identifier, String prefix) => {
        "type": "PrefixedIdentifier",
        "identifier": identifier,
        "prefix": prefix,
      };

  Map _buildProgram(
    Map? body, {
    String? astId,
    String? hash,
  }) =>
      {
        "type": "Program",
        "body": body,
        'astId': astId,
        'hash': hash,
      };

  Map _buildPropertyAccess(String name, Map? expression, bool isNullAware) => {
        "type": "PropertyAccess",
        "name": name,
        "expression": expression,
        'isNullAware': isNullAware,
      };

  Map _buildReturnStatement(Map? argument) => {
        "type": "ReturnStatement",
        "argument": argument,
      };

  Map _buildSetOrMapLiteral(List<Map> elements) => {
        "type": "SetOrMapLiteral",
        "elements": elements,
      };

  Map _buildSimpleFormalParameter(
          Map? type,
          String name,
          bool isNamed,
          bool isPositional,
          bool isOptional,
          bool isOptionalNamed,
          bool isOptionalPositional) =>
      {
        "type": "SimpleFormalParameter",
        "paramType": type,
        "name": name,
        "isNamed": isNamed,
        "isPositional": isPositional,
        "isOptional": isOptional,
        "isOptionalNamed": isOptionalNamed,
        "isOptionalPositional": isOptionalPositional
      };

  //构造函数参数类型
  Map _buildTypeName(String name) => {
        "type": "TypeName",
        "name": name,
      };

  Map _buildStringInterpolation(List<Map> elements) => {
        "type": "StringInterpolation",
        "elements": elements,
      };

  Map _buildSuperConstructorInvocation(Map? arguments) => {
        "type": "SuperConstructorInvocation",
        "arguments": arguments,
      };

  Map _buildSuperExpression(String name) => {
        "type": "SuperExpression",
        "name": name,
      };

  Map _buildSwitchCase(Map? condition, List<Map> statements) => {
        "type": "SwitchCase",
        "condition": condition,
        "statements": statements,
      };

  Map _buildSwitchDefault(List<Map> statements) => {
        "type": "SwitchDefault",
        "statements": statements,
      };

  Map _buildSwitchStatement(Map? checkValue, List<Map> body) => {
        "type": "SwitchStatement",
        "checkValue": checkValue,
        "body": body,
      };

  Map _buildVariableDeclaration(String name, Map? init) => {
        "type": "VariableDeclaration",
        "name": name,
        "init": init,
      };

  Map _buildVariableDeclarationList(
          Map? typeAnnotation, List<Map> declarations) =>
      {
        "type": "VariableDeclarationList",
        "typeAnnotation": typeAnnotation,
        "declarations": declarations,
      };

  Map _buildArgumentList(List<Map> argumentList) =>
      {"type": "ArgumentList", "argumentList": argumentList};

  Map _buildFormalParameterList(List<Map> parameterList) =>
      {"type": "FormalParameterList", "parameterList": parameterList};

  Map _buildImplementsClause(List<Map> implementList) =>
      {"type": "ImplementsClause", "implements": implementList};

  Map _buildWithClause(List<Map> mixinTypes) =>
      {"type": "WithClause", "mixinTypes": mixinTypes};

  Map _buildAnnotation(Map? id, Map? constructorName, Map? argumentList) => {
        "type": "Annotation",
        "id": id,
        "constructorName": constructorName,
        "argumentList": argumentList
      };

  Map _buildFunctionExpressionInvocation(Map? argumentList, Map? function) => {
        "type": "FunctionExpressionInvocation",
        "argumentList": argumentList,
        "function": function
      };

  Map _buildAsExpression(Map? expression, Map? asType) => {
        "type": "AsExpression",
        "expression": expression,
        "asType": asType,
      };

  Map _buildBlockFunctionBody(Map? block, bool isAsynchronous) => {
        "type": "BlockFunctionBody",
        "block": block,
        "isAsynchronous": isAsynchronous
      };

  Map _buildExpressionFunctionBody(Map? expression, bool isAsynchronous) => {
        "type": "ExpressionFunctionBody",
        "expression": expression,
        "isAsynchronous": isAsynchronous
      };

  Map _buildNullLiteral() => {"type": "NullLiteral"};

  Map _buildConditionalExpression(
          Map? condition, Map? thenExpression, Map? elseExpression) =>
      {
        "type": "ConditionalExpression",
        "condition": condition,
        "then": thenExpression,
        "else": elseExpression
      };

  Map _buildThisExpression() => {"type": "ThisExpression"};

  Map _buildConstructorName(String name, Map? type) => {
        "type": "ConstructorName",
        "name": name,
        "typeName": type,
      };

  Map _buildIsExpression(
          bool notOperator, Map? expression, String typeAnnotation) =>
      {
        'type': 'IsExpression',
        'not': notOperator,
        'expression': expression,
        'typeAnnotation': typeAnnotation
      };

  /// 遍历节点
  Map? _safelyVisitNode(AstNode? node) {
    if (node != null) {
      return node.accept(this);
    }
    return null;
  }

  /// 遍历节点列表
  List<Map> _safelyVisitNodeList(NodeList<AstNode>? nodes) {
    List<Map> maps = [];
    if (nodes != null) {
      int size = nodes.length;
      for (int i = 0; i < size; i++) {
        var node = nodes[i];
        maps.add(node.accept(this) ?? {});
      }
    }
    return maps;
  }

  @override
  visitAdjacentStrings(AdjacentStrings node) {
    if (_isDebug!) {
      stdout.writeln("visitAdjacentStrings => ${node.toString()}");
    }
    return null;
  }

  @override
  visitAnnotation(Annotation node) {
    if (_isDebug!) {
      stdout.writeln("visitAnnotation => ${node.toString()}");
    }

    return _buildAnnotation(
        _safelyVisitNode(node.name),
        _safelyVisitNode(node.constructorName),
        _safelyVisitNode(node.arguments));
  }

  @override
  visitArgumentList(ArgumentList node) {
    if (_isDebug!) {
      stdout.writeln("visitArgumentList => ${node.toString()}");
    }
    return _buildArgumentList(_safelyVisitNodeList(node.arguments));
  }

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitAssignmentExpression => ${node.toString()}; left type = ${node.leftHandSide.runtimeType}");
    }
    return _buildAssignmentExpression(_safelyVisitNode(node.leftHandSide),
        _safelyVisitNode(node.rightHandSide), node.operator.lexeme);
  }

  @override
  visitBinaryExpression(BinaryExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitBinaryExpression => ${node.toString()}");
    }

    return _buildBinaryExpression(_safelyVisitNode(node.leftOperand),
        _safelyVisitNode(node.rightOperand), node.operator.lexeme);
  }

  @override
  visitBlock(Block node) {
    if (_isDebug!) {
      stdout.writeln("visitBlock => ${node.toString()}");
    }

    return _buildBlock(_safelyVisitNodeList(node.statements));
  }

  @override
  visitBlockFunctionBody(BlockFunctionBody node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitBlockFunctionBody => ${node.toString()}, isAsync: ${node.isAsynchronous}");
    }

    return _buildBlockFunctionBody(
        _safelyVisitNode(node.block), node.isAsynchronous);
  }

  @override
  visitBooleanLiteral(BooleanLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitBooleanLiteral => ${node.toString()}");
    }
    return _buildBooleanLiteral(node.value);
  }

  @override
  visitBreakStatement(BreakStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitBreakStatement => ${node.toString()}");
    }
    return _buildBreakStatement();
  }

  @override
  visitCascadeExpression(CascadeExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitCascadeExpression => ${node.toString()}");
    }
    return null;
  }

  @override
  visitCatchClause(CatchClause node) {
    if (_isDebug!) {
      stdout.writeln("visitCatchClause => ${node.toString()}");
    }
    return null;
  }

  @override
  visitComment(Comment node) {
    if (_isDebug!) {
      stdout.writeln("visitComment => ${node.toString()}");
    }
    return null;
  }

  @override
  visitCommentReference(CommentReference node) {
    if (_isDebug!) {
      stdout.writeln("visitCommentReference => ${node.toString()}");
    }
    return null;
  }

  @override
  visitCompilationUnit(CompilationUnit node) {
    if (_isDebug!) {
      stdout.writeln("visitCompilationUnit => ${node.toString()}");
    }
    //遍历 import directives
    _safelyVisitNodeList(node.directives);

    var bodyList = <Map>[];

    //遍历到匹配的注解
    var declarations = node.declarations;
    // if (declarations.isNotEmpty == true) {
    //   for (var declare in declarations) {
    //     _referenceAstIds.clear();
    //     var res = declare.accept(this) ?? {};

    //     var annotationType = '';
    //     if (res['type'] == 'ClassDeclaration') {
    //       annotationType = fhClassAnnotation;
    //     } else if (res['type'] == 'FunctionDeclaration') {
    //       annotationType = fhFunctionAnnotation;
    //     } else {
    //       //只支持类和全局函数的声明，其他类型不支持
    //       continue;
    //     }
    //     var astId = generateAstId('$_filePath/${res['name']}');
    //     bodyList.add(AstCompilationUnit(
    //       name: res['name'],
    //       astId: astId,
    //       annotationType: annotationType,
    //       ast: _buildCompilationUnit(res,
    //           astId: astId,
    //           hash: res['hash'],
    //           annotationType: annotationType,
    //           refAstIds: List<String>.from(_referenceAstIds)),
    //       hash: res['hash'],
    //       filePath: _filePath,
    //     ).toMap());
    //   }
    // }
    return {'results': bodyList};
  }

  @override
  visitConditionalExpression(ConditionalExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitConditionalExpression => ${node.toString()}");
    }

    return _buildConditionalExpression(
        _safelyVisitNode(node.condition),
        _safelyVisitNode(node.thenExpression),
        _safelyVisitNode(node.elseExpression));
  }

  @override
  visitContinueStatement(ContinueStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitContinueStatement => ${node.toString()}");
    }
    return null;
  }

  @override
  visitDeclaredIdentifier(DeclaredIdentifier node) {
    if (_isDebug!) {
      stdout.writeln("visitDeclaredIdentifier => ${node.toString()}");
    }
    return _buildDeclaredIdentifier(_safelyVisitNode(node.identifier),
        _safelyVisitNode(node.type), node.keyword?.lexeme ?? '');
  }

  @override
  visitDefaultFormalParameter(DefaultFormalParameter node) {
    if (_isDebug!) {
      stdout.writeln("visitDefaultFormalParameter => ${node.toString()}");
    }

    return _buildDefaultFormalParameter(
        node.parameter.identifier?.name ?? '',
        _safelyVisitNode(node.defaultValue),
        node.isNamed,
        node.isOptional,
        node.isPositional,
        node.isOptionalNamed,
        node.isOptionalPositional);
  }

  @override
  visitDoStatement(DoStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitDoStatement => ${node.toString()}");
    }
    return null;
  }

  @override
  visitDottedName(DottedName node) {
    if (_isDebug!) {
      stdout.writeln("visitDottedName => ${node.toString()}");
    }
    return null;
  }

  @override
  visitDoubleLiteral(DoubleLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitDoubleLiteral => ${node.toString()}");
    }
    return _buildDoubleLiteral(node.value);
  }

  @override
  visitEmptyFunctionBody(EmptyFunctionBody node) {
    if (_isDebug!) {
      stdout.writeln("visitEmptyFunctionBody => ${node.toString()}");
    }
    return null;
  }

  @override
  visitEmptyStatement(EmptyStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitEmptyStatement => ${node.toString()}");
    }
    return null;
  }

  @override
  visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (_isDebug!) {
      stdout.writeln("visitExpressionFunctionBody => ${node.toString()}");
    }
    return _buildExpressionFunctionBody(
        _safelyVisitNode(node.expression), node.isAsynchronous);
  }

  @override
  visitExpressionStatement(ExpressionStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitExpressionStatement => ${node.toString()}");
    }
    return _buildExpressionStatement(_safelyVisitNode(node.expression));
  }

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (_isDebug!) {
      stdout.writeln("visitFieldDeclaration => ${node.toString()}");
    }

    return _buildFieldDeclaration(
        _safelyVisitNode(node.fields), _safelyVisitNodeList(node.metadata));
  }

  @override
  visitFieldFormalParameter(FieldFormalParameter node) {
    if (_isDebug!) {
      stdout.writeln("visitFieldFormalParameter => ${node.toString()}");
    }

    return _buildFieldFormalParameter(
        node.identifier.name,
        _safelyVisitNode(node.typeParameters),
        _safelyVisitNode(node.parameters),
        node.thisKeyword.lexeme == "this",
        node.isNamed,
        node.isOptional,
        node.isPositional,
        node.isOptionalNamed,
        node.isOptionalPositional);
  }

  @override
  visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    if (_isDebug!) {
      stdout.writeln("visitForEachPartsWithDeclaration => ${node.toString()}");
    }

    return _buildForEachPartsWithDeclaration(
        _safelyVisitNode(node.loopVariable), _safelyVisitNode(node.iterable));
  }

  @override
  visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    if (_isDebug!) {
      stdout.writeln("visitForEachPartsWithIdentifier => ${node.toString()}");
    }

    return _buildForEachPartsWithIdentifier(
        _safelyVisitNode(node.identifier), _safelyVisitNode(node.iterable));
  }

  @override
  visitForElement(ForElement node) {
    if (_isDebug!) {
      stdout.writeln("visitForElement => ${node.toString()}");
    }

    return null;
  }

  @override
  visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    if (_isDebug!) {
      stdout.writeln("visitForPartsWithDeclarations => ${node.toString()}");
    }

    return _buildForPartsWithDeclarations(_safelyVisitNode(node.variables),
        _safelyVisitNode(node.condition), _safelyVisitNodeList(node.updaters));
  }

  @override
  visitForPartsWithExpression(ForPartsWithExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitForPartsWithExpression => ${node.toString()}");
    }

    return _buildForPartsWithExpression(_safelyVisitNode(node.initialization),
        _safelyVisitNode(node.condition), _safelyVisitNodeList(node.updaters));
  }

  @override
  visitForStatement(ForStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitForStatement => ${node.toString()}");
    }
    return _buildForStatement(
        _safelyVisitNode(node.forLoopParts), _safelyVisitNode(node.body));
  }

  @override
  visitFormalParameterList(FormalParameterList node) {
    if (_isDebug!) {
      stdout.writeln("visitFormalParameterList => ${node.toString()}");
    }
    return _buildFormalParameterList(_safelyVisitNodeList(node.parameters));
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitFunctionDeclaration => ${node.toString()}, Source: ${node.toSource()}");
    }
    //是否有[fhFunctionAnnotation]注解
    var haveAnnotation = false;
    // if (node.metadata.isNotEmpty == true) {
    //   for (var md in node.metadata) {
    //     if (md.name.name == fhFunctionAnnotation) {
    //       haveAnnotation = true;
    //     }
    //   }
    // }
    // if (haveAnnotation) {
    var digest = md5.convert(Utf8Encoder().convert(node.toSource()));
    var hash = hex.encode(digest.bytes);
    return _buildFunctionDeclaration(
        node.name.name,
        _safelyVisitNode(node.functionExpression),
        _safelyVisitNode(node.returnType),
        hash: hash);
    // } else {
    //   return null;
    // }
    // return null;
  }

  @override
  visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitFunctionDeclarationStatement => ${node.toString()}");
    }

    return _safelyVisitNode(node.functionDeclaration);
  }

  @override
  visitFunctionExpression(FunctionExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitFunctionExpression => ${node.toString()}");
    }

    return _buildFunctionExpression(
      _safelyVisitNode(node.parameters),
      _safelyVisitNode(node.body),
    );
  }

  @override
  visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (_isDebug!) {
      stdout.writeln("visitFunctionExpressionInvocation => ${node.toString()}");
    }
    return _buildFunctionExpressionInvocation(
        _safelyVisitNode(node.argumentList), _safelyVisitNode(node.function));
  }

  @override
  visitFunctionTypeAlias(FunctionTypeAlias functionTypeAlias) {
    if (_isDebug!) {
      stdout
          .writeln("visitFunctionTypeAlias => ${functionTypeAlias.toString()}");
    }

    return null;
  }

  @override
  visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    if (_isDebug!) {
      stdout.writeln("visitFunctionTypedFormalParameter => ${node.toString()}");
    }

    return _buildFunctionTypedFormalParameter(_safelyVisitNode(node.identifier),
        _safelyVisitNode(node.returnType), _safelyVisitNode(node.parameters));
  }

  @override
  visitGenericFunctionType(GenericFunctionType node) {
    if (_isDebug!) {
      stdout.writeln("visitGenericFunctionType => ${node.toString()}");
    }
    return null;
  }

  @override
  visitGenericTypeAlias(GenericTypeAlias node) {
    if (_isDebug!) {
      stdout.writeln("visitGenericTypeAlias => ${node.toString()}");
    }
    return null;
  }

  @override
  visitHideCombinator(HideCombinator node) {
    if (_isDebug!) {
      stdout.writeln("visitHideCombinator => ${node.toString()}");
    }
    return null;
  }

  @override
  visitIfElement(IfElement node) {
    if (_isDebug!) {
      stdout.writeln("visitIfElement => ${node.toString()}");
    }
    return null;
  }

  @override
  visitIfStatement(IfStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitIfStatement => ${node.toString()}");
    }

    return _buildIfStatement(
        _safelyVisitNode(node.condition),
        _safelyVisitNode(node.thenStatement),
        _safelyVisitNode(node.elseStatement));
  }

  @override
  visitIndexExpression(IndexExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitIndexExpression => ${node.toString()}");
    }

    return _buildIndexExpression(_safelyVisitNode(node.target),
        _safelyVisitNode(node.index), node.isNullAware);
  }

  @override
  visitIntegerLiteral(IntegerLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitIntegerLiteral => ${node.toString()}");
    }

    return _buildIntegerLiteral(node.value);
  }

  @override
  visitInterpolationExpression(InterpolationExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitInterpolationExpression => ${node.toString()}");
    }

    return _buildInterpolationExpression(_safelyVisitNode(node.expression));
  }

  @override
  visitInterpolationString(InterpolationString node) {
    if (_isDebug!) {
      stdout.writeln("visitInterpolationString => ${node.toString()}");
    }

    return _buildInterpolationString(node.value);
  }

  @override
  visitLabel(Label node) {
    if (_isDebug!) {
      stdout.writeln("visitLabel => ${node.toString()}");
    }
    return _safelyVisitNode(node.label);
  }

  @override
  visitLabeledStatement(LabeledStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitLabeledStatement => ${node.toString()}");
    }

    return null;
  }

  @override
  visitListLiteral(ListLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitListLiteral => ${node.toString()}");
    }

    return _buildListLiteral(_safelyVisitNodeList(node.elements));
  }

  @override
  visitMapLiteralEntry(MapLiteralEntry node) {
    if (_isDebug!) {
      stdout.writeln("visitMapLiteralEntry => ${node.toString()}");
    }

    return _buildMapLiteralEntry(
        _safelyVisitNode(node.key), _safelyVisitNode(node.value));
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    if (_isDebug!) {
      stdout.writeln("visitMethodDeclaration => ${node.toString()}");
    }

    return _buildMethodDeclaration(
      node.name.name,
      _safelyVisitNode(node.parameters),
      _safelyVisitNode(node.typeParameters),
      _safelyVisitNode(node.body),
      _safelyVisitNode(node.returnType),
    );
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitMethodInvocation => ${node.toString()}, target=> ${node.target}, isNullAware=> ${node.isNullAware}");
    }
    Map? callee;

    if (node.target != null) {
      node.target!.accept(this);

      callee = {
        "type": "MemberExpression",
        "target": _safelyVisitNode(node.target),
        "property": _safelyVisitNode(node.methodName),
      };
    } else {
      //先查找是否ast class 的构造函数
      var methodName = node.methodName.name;
      //通过import 遍历寻找ast class 文件

      // for (var p in _importPaths) {
      //   //检查是否引用AstClass 类构造函数 或 全局方法函数
      //   for (var unit in preCompile!.unitList!) {
      //     if (path.equals(p, unit.filePath!) && methodName == unit.name) {
      //       //找到项目中匹配的 ast class 记录
      //       callee = unit.toMap();
      //       //存储引用的ast class
      //       if (!_referenceAstIds.contains(unit.astId)) {
      //         _referenceAstIds.add(unit.astId!);
      //       }
      //       if (_isDebug!) {
      //         stdout.writeln(
      //             "Found import file:<$p> witch contains method: $methodName");
      //       }
      //       break;
      //     }
      //   }
      // }
      //如果没有查到ast class，则正常填充callee
      if (callee == null) {
        callee = _safelyVisitNode(node.methodName);
      }
    }
    return _buildMethodInvocation(callee, _safelyVisitNode(node.typeArguments),
        _safelyVisitNode(node.argumentList), node.isNullAware);
  }

  @override
  visitNamedExpression(NamedExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitNamedExpression => ${node.toString()}");
    }

    return _buildNamedExpression(
        node.name.label.name, _safelyVisitNode(node.expression));
  }

  @override
  visitNullLiteral(NullLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitNullLiteral => ${node.toString()}");
    }
    return _buildNullLiteral();
  }

  @override
  visitParenthesizedExpression(ParenthesizedExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitParenthesizedExpression => ${node.toString()}");
    }
    return _safelyVisitNode(node.expression);
  }

  @override
  visitPostfixExpression(PostfixExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitPostfixExpression => ${node.toString()}");
    }
    Map? map;
    if (node.operator.type == TokenType.PLUS_PLUS ||
        node.operator.type == TokenType.MINUS_MINUS ||
        node.operator.type == TokenType.BANG) {
      map = _buildPrefixExpression(
          node.operator.lexeme, false, _safelyVisitNode(node.operand));
    }
    return map;
  }

  @override
  visitPrefixExpression(PrefixExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitPrefixExpression => ${node.toString()}");
    }
    Map? map;
    if (node.operator.type == TokenType.PLUS_PLUS ||
        node.operator.type == TokenType.MINUS_MINUS ||
        node.operator.type == TokenType.BANG ||
        node.operator.type == TokenType.MINUS ||
        node.operator.type == TokenType.TILDE) {
      map = _buildPrefixExpression(
          node.operator.lexeme, true, _safelyVisitNode(node.operand));
    }
    return map;
  }

  @override
  Map? visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitPrefixedIdentifier => ${node.toString()}; identifier: ${node.identifier} & prefix: ${node.prefix}");
    }

    return _buildPrefixedIdentifier(node.identifier.name, node.prefix.name);
  }

  @override
  Map? visitProgram(Program node) {
    return _buildProgram(_safelyVisitNode(node.expression));
  }

  @override
  Map? visitPropertyAccess(PropertyAccess node) {
    if (_isDebug!) {
      stdout.writeln("visitPropertyAccess => ${node.toString()}");
    }
    return _buildPropertyAccess(node.propertyName.name,
        _safelyVisitNode(node.target), node.isNullAware);
  }

  @override
  Map? visitReturnStatement(ReturnStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitReturnStatement => ${node.toString()}");
    }
    return _buildReturnStatement(_safelyVisitNode(node.expression));
  }

  @override
  Map? visitScriptTag(ScriptTag node) {
    if (_isDebug!) {
      stdout.writeln("visitScriptTag => ${node.toString()}");
    }
    return null;
  }

  @override
  visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitSetOrMapLiteral => ${node.toString()}");
    }

    return _buildSetOrMapLiteral(_safelyVisitNodeList(node.elements));
  }

  @override
  visitSimpleFormalParameter(SimpleFormalParameter node) {
    if (_isDebug!) {
      stdout.writeln("visitSimpleFormalParameter => ${node.toString()}");
    }

    return _buildSimpleFormalParameter(
        _safelyVisitNode(node.type),
        node.identifier?.name ?? '',
        node.isNamed,
        node.isPositional,
        node.isOptional,
        node.isOptionalNamed,
        node.isOptionalPositional);
  }

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    if (_isDebug!) {
      stdout.writeln("visitSimpleIdentifier => ${node.toString()}");
    }
    return _buildSimpleIdentifier(node.name);
  }

  @override
  visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitSimpleStringLiteral => ${node.toString()}");
    }

    return _buildStringLiteral(node.value);
  }

  @override
  visitSpreadElement(SpreadElement node) {
    if (_isDebug!) {
      stdout.writeln("visitSpreadElement => ${node.toString()}");
    }

    return null;
  }

  @override
  visitStringInterpolation(StringInterpolation node) {
    if (_isDebug!) {
      stdout.writeln(
          "visitStringInterpolation => ${node.toString()}\n elements size=${node.elements.length}");
    }

    return _buildStringInterpolation(_safelyVisitNodeList(node.elements));
  }

  @override
  visitSwitchCase(SwitchCase node) {
    if (_isDebug!) {
      stdout.writeln("visitSwitchCase => ${node.toString()}");
    }
    return _buildSwitchCase(_safelyVisitNode(node.expression),
        _safelyVisitNodeList(node.statements));
  }

  @override
  visitSwitchDefault(SwitchDefault node) {
    if (_isDebug!) {
      stdout.writeln("visitSwitchDefault => ${node.toString()}");
    }

    return _buildSwitchDefault(_safelyVisitNodeList(node.statements));
  }

  @override
  visitSwitchStatement(SwitchStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitSwitchStatement => ${node.toString()}");
    }

    return _buildSwitchStatement(
        _safelyVisitNode(node.expression), _safelyVisitNodeList(node.members));
  }

  @override
  visitSymbolLiteral(SymbolLiteral node) {
    if (_isDebug!) {
      stdout.writeln("visitSymbolLiteral => ${node.toString()}");
    }

    return null;
  }

  @override
  visitThisExpression(ThisExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitThisExpression => ${node.toString()}");
    }
    return _buildThisExpression();
  }

  @override
  visitThrowExpression(ThrowExpression node) {
    if (_isDebug!) {
      stdout.writeln("visitThrowExpression => ${node.toString()}");
    }
    return null;
  }

  @override
  visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (_isDebug!) {
      stdout.writeln("visitTopLevelVariableDeclaration => ${node.toString()}");
    }
    return _safelyVisitNode(node.variables);
  }

  @override
  visitTryStatement(TryStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitTryStatement => ${node.toString()}");
    }
    return null;
  }

  @override
  visitTypeArgumentList(TypeArgumentList node) {
    if (_isDebug!) {
      stdout.writeln("visitTypeArgumentList => ${node.toString()}");
    }

    return _buildTypeArgumentList(_safelyVisitNodeList(node.arguments));
  }

  @override
  visitTypeParameter(TypeParameter node) {
    if (_isDebug!) {
      stdout.writeln("visitTypeParameter => ${node.toString()}");
    }
    return null;
  }

  @override
  visitTypeParameterList(TypeParameterList node) {
    if (_isDebug!) {
      stdout.writeln("visitTypeParameterList => ${node.toString()}");
    }
    return null;
  }

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    if (_isDebug!) {
      stdout.writeln("visitVariableDeclaration => ${node.toString()}");
    }
    return _buildVariableDeclaration(
        node.name.name, _safelyVisitNode(node.initializer));
  }

  @override
  visitVariableDeclarationList(VariableDeclarationList node) {
    if (_isDebug!) {
      stdout.writeln("visitVariableDeclarationList => ${node.toString()}");
    }
    return _buildVariableDeclarationList(
        _safelyVisitNode(node.type), _safelyVisitNodeList(node.variables));
  }

  @override
  visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitVariableDeclarationStatement => ${node.toString()}");
    }

    return _safelyVisitNode(node.variables);
  }

  @override
  visitWhileStatement(WhileStatement node) {
    if (_isDebug!) {
      stdout.writeln("visitWhileStatement => ${node.toString()}");
    }
    return null;
  }

  @override
  Map? visitFunctionReference(FunctionReference node) {
    // TODO: implement visitFunctionReference
    throw UnimplementedError();
  }

  @override
  Map? visitImplicitCallReference(ImplicitCallReference node) {
    // TODO: implement visitImplicitCallReference
    throw UnimplementedError();
  }

  @override
  Map? visitNamedType(NamedType node) {
    // TODO: implement visitNamedType
    throw UnimplementedError();
  }

  @override
  Map? visitTypeLiteral(TypeLiteral node) {
    // TODO: implement visitTypeLiteral
    throw UnimplementedError();
  }
}
