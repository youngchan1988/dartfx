// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/visitor.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:meta/meta.dart';

import 'ast.dart';

/// A visitor used to write a source representation of a visited AST node (and
/// all of it's children) to a sink.
class ToSourceVisitor implements AstVisitor<void> {
  /// The sink to which the source is to be written.
  @protected
  final StringSink sink;

  /// Initialize a newly created visitor to write source code representing the
  /// visited nodes to the given [sink].
  ToSourceVisitor(this.sink);

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    _visitNodeList(node.strings, separator: ' ');
  }

  @override
  void visitAnnotation(Annotation node) {
    sink.write('@');
    _visitNode(node.name);
    _visitNode(node.typeArguments);
    _visitNode(node.constructorName, prefix: '.');
    _visitNode(node.arguments);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    sink.write('(');
    _visitNodeList(node.arguments, separator: ', ');
    sink.write(')');
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _visitNode(node.leftHandSide);
    sink.write(' ');
    sink.write(node.operator.lexeme);
    sink.write(' ');
    _visitNode(node.rightHandSide);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _writeOperand(node, node.leftOperand);
    sink.write(' ');
    sink.write(node.operator.lexeme);
    sink.write(' ');
    _writeOperand(node, node.rightOperand);
  }

  @override
  void visitBlock(Block node) {
    sink.write('{');
    _visitNodeList(node.statements, separator: ' ');
    sink.write('}');
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    var keyword = node.keyword;
    if (keyword != null) {
      sink.write(keyword.lexeme);
      if (node.star != null) {
        sink.write('*');
      }
      sink.write(' ');
    }
    _visitNode(node.block);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    sink.write(node.literal.lexeme);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    sink.write('break');
    _visitNode(node.label, prefix: ' ');
    sink.write(';');
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    _visitNode(node.target);
    _visitNodeList(node.cascadeSections);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _visitNode(node.exceptionType, prefix: 'on ');
    if (node.catchKeyword != null) {
      if (node.exceptionType != null) {
        sink.write(' ');
      }
      sink.write('catch (');
      _visitNode(node.exceptionParameter);
      _visitNode(node.stackTraceParameter, prefix: ', ');
      sink.write(') ');
    } else {
      sink.write(' ');
    }
    _visitNode(node.body);
  }

  @override
  void visitComment(Comment node) {}

  @override
  void visitCommentReference(CommentReference node) {}

  @override
  void visitCompilationUnit(CompilationUnit node) {
    var scriptTag = node.scriptTag;
    NodeList<Directive> directives = node.directives;
    _visitNode(scriptTag);
    String prefix = scriptTag == null ? '' : ' ';
    _visitNodeList(directives, prefix: prefix, separator: ' ');
    prefix = scriptTag == null && directives.isEmpty ? '' : ' ';
    _visitNodeList(node.declarations, prefix: prefix, separator: ' ');
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _visitNode(node.condition);
    sink.write(' ? ');
    _visitNode(node.thenExpression);
    sink.write(' : ');
    _visitNode(node.elseExpression);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    sink.write('continue');
    _visitNode(node.label, prefix: ' ');
    sink.write(';');
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.keyword, suffix: ' ');
    _visitNode(node.type, suffix: ' ');
    _visitNode(node.identifier);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    _visitNode(node.parameter);
    var separator = node.separator;
    if (separator != null) {
      if (separator.lexeme != ':') {
        sink.write(' ');
      }
      sink.write(separator.lexeme);
      _visitNode(node.defaultValue, prefix: ' ');
    }
  }

  @override
  void visitDoStatement(DoStatement node) {
    sink.write('do ');
    _visitNode(node.body);
    sink.write(' while (');
    _visitNode(node.condition);
    sink.write(');');
  }

  @override
  void visitDottedName(DottedName node) {
    _visitNodeList(node.components, separator: '.');
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    sink.write(node.literal.lexeme);
  }

  @override
  void visitEmptyFunctionBody(EmptyFunctionBody node) {
    sink.write(';');
  }

  @override
  void visitEmptyStatement(EmptyStatement node) {
    sink.write(';');
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    var keyword = node.keyword;
    if (keyword != null) {
      sink.write(keyword.lexeme);
      if (node.star != null) {
        sink.write('*');
      }
      sink.write(' ');
    }
    sink.write('${node.functionDefinition.lexeme} ');
    _visitNode(node.expression);
    if (node.semicolon != null) {
      sink.write(';');
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    _visitNode(node.expression);
    sink.write(';');
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.abstractKeyword, suffix: ' ');
    _visitToken(node.externalKeyword, suffix: ' ');
    _visitToken(node.staticKeyword, suffix: ' ');
    _visitNode(node.fields);
    sink.write(';');
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.requiredKeyword, suffix: ' ');
    _visitToken(node.covariantKeyword, suffix: ' ');
    _visitToken(node.keyword, suffix: ' ');
    _visitNode(node.type, suffix: ' ');
    sink.write('this.');
    _visitNode(node.identifier);
    _visitNode(node.typeParameters);
    _visitNode(node.parameters);
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    _visitNode(node.loopVariable);
    sink.write(' in ');
    _visitNode(node.iterable);
  }

  @override
  void visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    _visitNode(node.identifier);
    sink.write(' in ');
    _visitNode(node.iterable);
  }

  @override
  void visitForElement(ForElement node) {
    _visitToken(node.awaitKeyword, suffix: ' ');
    sink.write('for (');
    _visitNode(node.forLoopParts);
    sink.write(') ');
    _visitNode(node.body);
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    String? groupEnd;
    sink.write('(');
    NodeList<FormalParameter> parameters = node.parameters;
    int size = parameters.length;
    for (int i = 0; i < size; i++) {
      FormalParameter parameter = parameters[i];
      if (i > 0) {
        sink.write(', ');
      }
      if (groupEnd == null && parameter is DefaultFormalParameter) {
        if (parameter.isNamed) {
          groupEnd = '}';
          sink.write('{');
        } else {
          groupEnd = ']';
          sink.write('[');
        }
      }
      parameter.accept(this);
    }
    if (groupEnd != null) {
      sink.write(groupEnd);
    }
    sink.write(')');
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    _visitNode(node.variables);
    sink.write(';');
    _visitNode(node.condition, prefix: ' ');
    sink.write(';');
    _visitNodeList(node.updaters, prefix: ' ', separator: ', ');
  }

  @override
  void visitForPartsWithExpression(ForPartsWithExpression node) {
    _visitNode(node.initialization);
    sink.write(';');
    _visitNode(node.condition, prefix: ' ');
    sink.write(';');
    _visitNodeList(node.updaters, prefix: ' ', separator: ', ');
  }

  @override
  void visitForStatement(ForStatement node) {
    if (node.awaitKeyword != null) {
      sink.write('await ');
    }
    sink.write('for (');
    _visitNode(node.forLoopParts);
    sink.write(') ');
    _visitNode(node.body);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.externalKeyword, suffix: ' ');
    _visitNode(node.returnType, suffix: ' ');
    _visitToken(node.propertyKeyword, suffix: ' ');
    _visitNode(node.name);
    _visitNode(node.functionExpression);
  }

  @override
  void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    _visitNode(node.functionDeclaration);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _visitNode(node.typeParameters);
    _visitNode(node.parameters);
    _visitFunctionBody(node.body);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _visitNode(node.function);
    _visitNode(node.typeArguments);
    _visitNode(node.argumentList);
  }

  @override
  void visitFunctionReference(FunctionReference node) {
    _visitNode(node.function);
    _visitNode(node.typeArguments);
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    sink.write('typedef ');
    _visitNode(node.returnType, suffix: ' ');
    _visitNode(node.name);
    _visitNode(node.typeParameters);
    _visitNode(node.parameters);
    sink.write(';');
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.requiredKeyword, suffix: ' ');
    _visitToken(node.covariantKeyword, suffix: ' ');
    _visitNode(node.returnType, suffix: ' ');
    _visitNode(node.identifier);
    _visitNode(node.typeParameters);
    _visitNode(node.parameters);
    if (node.question != null) {
      sink.write('?');
    }
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _visitNode(node.returnType);
    sink.write(' Function');
    _visitNode(node.typeParameters);
    _visitNode(node.parameters);
    if (node.question != null) {
      sink.write('?');
    }
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    sink.write('typedef ');
    _visitNode(node.name);
    _visitNode(node.typeParameters);
    sink.write(' = ');
    _visitNode(node.type);
    sink.write(';');
  }

  @override
  void visitHideCombinator(HideCombinator node) {
    sink.write('hide ');
    _visitNodeList(node.hiddenNames, separator: ', ');
  }

  @override
  void visitIfElement(IfElement node) {
    sink.write('if (');
    _visitNode(node.condition);
    sink.write(') ');
    _visitNode(node.thenElement);
    _visitNode(node.elseElement, prefix: ' else ');
  }

  @override
  void visitIfStatement(IfStatement node) {
    sink.write('if (');
    _visitNode(node.condition);
    sink.write(') ');
    _visitNode(node.thenStatement);
    _visitNode(node.elseStatement, prefix: ' else ');
  }

  @override
  void visitImplicitCallReference(ImplicitCallReference node) {
    _visitNode(node.expression);
    _visitNode(node.typeArguments);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.isCascaded) {
      _visitToken(node.period);
    } else {
      _visitNode(node.target);
    }
    _visitToken(node.question);
    _visitToken(node.leftBracket);
    _visitNode(node.index);
    _visitToken(node.rightBracket);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    sink.write(node.literal.lexeme);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    if (node.rightBracket != null) {
      sink.write('\${');
      _visitNode(node.expression);
      sink.write('}');
    } else {
      sink.write('\$');
      _visitNode(node.expression);
    }
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    sink.write(node.contents.lexeme);
  }

  @override
  void visitLabel(Label node) {
    _visitNode(node.label);
    sink.write(':');
  }

  @override
  void visitLabeledStatement(LabeledStatement node) {
    _visitNodeList(node.labels, separator: ' ', suffix: ' ');
    _visitNode(node.statement);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _visitToken(node.constKeyword, suffix: ' ');
    _visitNode(node.typeArguments);
    sink.write('[');
    _visitNodeList(node.elements, separator: ', ');
    sink.write(']');
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    _visitNode(node.key);
    sink.write(' : ');
    _visitNode(node.value);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.externalKeyword, suffix: ' ');
    _visitNode(node.returnType, suffix: ' ');
    _visitToken(node.propertyKeyword, suffix: ' ');
    _visitToken(node.operatorKeyword, suffix: ' ');
    _visitNode(node.name);
    _visitFunctionBody(node.body);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _visitNode(node.target);
    _visitToken(node.operator);
    _visitNode(node.methodName);
    _visitNode(node.typeArguments);
    _visitNode(node.argumentList);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    _visitNode(node.name);
    _visitNode(node.expression, prefix: ' ');
  }

  @override
  void visitNamedType(NamedType node) {
    _visitNode(node.name);
    _visitNode(node.typeArguments);
    if (node.question != null) {
      sink.write('?');
    }
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    sink.write('null');
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    sink.write('(');
    _visitNode(node.expression);
    sink.write(')');
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _writeOperand(node, node.operand);
    sink.write(node.operator.lexeme);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _visitNode(node.prefix);
    sink.write('.');
    _visitNode(node.identifier);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    sink.write(node.operator.lexeme);
    _writeOperand(node, node.operand);
  }

  @override
  void visitProgram(Program node) {
    sink.write('(');
    _visitNode(node.expression);
    sink.write(')');
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.isCascaded) {
      sink.write(node.operator.lexeme);
    } else {
      _visitNode(node.target);
      sink.write(node.operator.lexeme);
    }
    _visitNode(node.propertyName);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    var expression = node.expression;
    if (expression == null) {
      sink.write('return;');
    } else {
      sink.write('return ');
      expression.accept(this);
      sink.write(';');
    }
  }

  @override
  void visitScriptTag(ScriptTag node) {
    sink.write(node.scriptTag.lexeme);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _visitToken(node.constKeyword, suffix: ' ');
    _visitNode(node.typeArguments);
    sink.write('{');
    _visitNodeList(node.elements, separator: ', ');
    sink.write('}');
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.requiredKeyword, suffix: ' ');
    _visitToken(node.covariantKeyword, suffix: ' ');
    _visitToken(node.keyword, suffix: ' ');
    _visitNode(node.type);
    if (node.type != null && node.identifier != null) {
      sink.write(' ');
    }
    _visitNode(node.identifier);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    sink.write(node.token.lexeme);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    sink.write(node.literal.lexeme);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    sink.write(node.spreadOperator.lexeme);
    _visitNode(node.expression);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _visitNodeList(node.elements);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _visitNodeList(node.labels, separator: ' ', suffix: ' ');
    sink.write('case ');
    _visitNode(node.expression);
    sink.write(': ');
    _visitNodeList(node.statements, separator: ' ');
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _visitNodeList(node.labels, separator: ' ', suffix: ' ');
    sink.write('default: ');
    _visitNodeList(node.statements, separator: ' ');
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    sink.write('switch (');
    _visitNode(node.expression);
    sink.write(') {');
    _visitNodeList(node.members, separator: ' ');
    sink.write('}');
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    sink.write('#');
    List<Token> components = node.components;
    for (int i = 0; i < components.length; i++) {
      if (i > 0) {
        sink.write('.');
      }
      sink.write(components[i].lexeme);
    }
  }

  @override
  void visitThisExpression(ThisExpression node) {
    sink.write('this');
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    sink.write('throw ');
    _visitNode(node.expression);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    _visitToken(node.externalKeyword, suffix: ' ');
    _visitNode(node.variables, suffix: ';');
  }

  @override
  void visitTryStatement(TryStatement node) {
    sink.write('try ');
    _visitNode(node.body);
    _visitNodeList(node.catchClauses, prefix: ' ', separator: ' ');
    _visitNode(node.finallyBlock, prefix: ' finally ');
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    sink.write('<');
    _visitNodeList(node.arguments, separator: ', ');
    sink.write('>');
  }

  @override
  void visitTypeLiteral(TypeLiteral node) {
    _visitNode(node.type);
  }

  @override
  void visitTypeParameter(TypeParameter node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    // TODO (kallentu) : Clean up TypeParameterImpl casting once variance is
    // added to the interface.
    var varianceKeyword = (node as TypeParameterImpl).varianceKeyword;
    if (varianceKeyword != null) {
      sink.write(varianceKeyword.lexeme + ' ');
    }
    _visitNode(node.name);
    _visitNode(node.bound, prefix: ' extends ');
  }

  @override
  void visitTypeParameterList(TypeParameterList node) {
    sink.write('<');
    _visitNodeList(node.typeParameters, separator: ', ');
    sink.write('>');
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitNode(node.name);
    _visitNode(node.initializer, prefix: ' = ');
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    _visitNodeList(node.metadata, separator: ' ', suffix: ' ');
    _visitToken(node.keyword, suffix: ' ');
    _visitNode(node.type, suffix: ' ');
    _visitNodeList(node.variables, separator: ', ');
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _visitNode(node.variables);
    sink.write(';');
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    sink.write('while (');
    _visitNode(node.condition);
    sink.write(') ');
    _visitNode(node.body);
  }

  /// Visit the given function [body], printing a prefix before if the body
  /// is not empty.
  void _visitFunctionBody(FunctionBody body) {
    if (body is! EmptyFunctionBody) {
      sink.write(' ');
    }
    _visitNode(body);
  }

  /// Print the given [node], printing the [prefix] before the node,
  /// and [suffix] after the node, if it is non-`null`.
  void _visitNode(AstNode? node, {String prefix = '', String suffix = ''}) {
    if (node != null) {
      sink.write(prefix);
      node.accept(this);
      sink.write(suffix);
    }
  }

  /// Print a list of [nodes], separated by the given [separator]; if the list
  /// is not empty print [prefix] before the first node, and [suffix] after
  /// the last node.
  void _visitNodeList(List<AstNode> nodes,
      {String prefix = '', String separator = '', String suffix = ''}) {
    var length = nodes.length;
    if (length > 0) {
      sink.write(prefix);
      for (int i = 0; i < length; i++) {
        if (i > 0) {
          sink.write(separator);
        }
        nodes[i].accept(this);
      }
      sink.write(suffix);
    }
  }

  /// Print the given [token].
  void _visitToken(Token? token, {String suffix = ''}) {
    if (token != null) {
      sink.write(token.lexeme);
      sink.write(suffix);
    }
  }

  void _writeOperand(Expression node, Expression operand) {
    bool needsParenthesis = operand.precedence < node.precedence;
    if (needsParenthesis) {
      sink.write('(');
    }
    operand.accept(this);
    if (needsParenthesis) {
      sink.write(')');
    }
  }
}
