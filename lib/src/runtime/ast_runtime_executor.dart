///
/// ProjectName: flutterhot
/// Author: youngchan
/// CreateDate: 2020/12/22 10:14 AM
/// Copyright: ©2020 NEW CORE Technology Co. Ltd. All rights reserved.
/// Description: Ast Runtime 动态执行器
///

import 'ast_runtime_node.dart';
import 'ast_context.dart';

/// Runtime executor interface
///
/// Clients may not extend, implement or mix-in this class.
abstract class AstRuntimeExecutor {
  dynamic execute(AstContext? astContext, AstRuntimeNode? astNode);

  dynamic executeAsExpression(AstContext astContext, AsExpression expression);

  dynamic executeIsExpression(AstContext astContext, IsExpression expression);

  dynamic executeAssignmentExpression(
      AstContext astContext, AssignmentExpression expression);

  Future executeAssignmentExpressionAsync(
      AstContext astContext, AssignmentExpression expression);

  dynamic executeBinaryExpression(
      AstContext astContext, BinaryExpression expression);

  dynamic executeBlock(AstContext astContext, Block block);

  Future executeBlockAsync(AstContext astContext, Block block);

  dynamic executeBlockFunctionBody(
      AstContext? astContext, BlockFunctionBody? functionBody);

  Future executeBlockFunctionBodyAsync(
      AstContext astContext, BlockFunctionBody? functionBody);

  dynamic executeBooleanLiteral(
      AstContext astContext, BooleanLiteral booleanLiteral);

  dynamic executeConditionalExpression(
      AstContext astContext, ConditionalExpression expression);

  dynamic executeDoubleLiteral(
      AstContext astContext, DoubleLiteral doubleLiteral);

  dynamic executeExpressionFunctionBody(
      AstContext astContext, ExpressionFunctionBody? functionBody);

  dynamic executeExpressionFunctionBodyAsync(
      AstContext astContext, ExpressionFunctionBody? functionBody);

  dynamic executeExpressionStatement(
      AstContext astContext, ExpressionStatement statement);

  dynamic executeForStatement(AstContext astContext, ForStatement statement);

  Future executeForStatementAsync(
      AstContext astContext, ForStatement statement);

  dynamic executeFunctionExpression(
      AstContext astContext, FunctionExpression expression);

  dynamic executeFunctionExpressionInvocation(
      AstContext astContext, FunctionExpressionInvocation expressionInvocation);

  dynamic executeIfStatement(AstContext astContext, IfStatement statement);

  Future executeIfStatementAsync(AstContext astContext, IfStatement statement);

  dynamic executeIndexExpression(
      AstContext astContext, IndexExpression expression);

  dynamic executeInstanceCreationExpression(
      AstContext astContext, InstanceCreationExpression expression);

  dynamic executeIntegerLiteral(
      AstContext astContext, IntegerLiteral integerLiteral);

  dynamic executeListLiteral(AstContext astContext, ListLiteral listLiteral);

  dynamic executeNamedExpression(
      AstContext astContext, NamedExpression expression);

  dynamic executeMethodInvocation(
      AstContext astContext, MethodInvocation methodInvocation);

  dynamic executePrefixedIdentifier(
      AstContext astContext, PrefixedIdentifier identifier);

  dynamic executePrefixExpression(
      AstContext astContext, PrefixExpression expression);

  dynamic executePropertyAccess(
      AstContext astContext, PropertyAccess propertyAccess);

  dynamic executeReturnStatement(
      AstContext astContext, ReturnStatement returnStatement);

  dynamic executeSetOrMapLiteral(
      AstContext astContext, SetOrMapLiteral mapLiteral);

  dynamic executeSimpleIdentifier(
      AstContext astContext, SimpleIdentifier identifier);

  dynamic executeStringLiteral(
      AstContext astContext, StringLiteral stringLiteral);

  dynamic executeStringInterpolation(
      AstContext astContext, StringInterpolation interpolation);

  dynamic executeSwitchStatement(
      AstContext astContext, SwitchStatement statement);

  Future executeSwitchStatementAsync(
      AstContext astContext, SwitchStatement statement);

  dynamic executeThisExpression(
      AstContext astContext, ThisExpression expression);

  dynamic executeVariableDeclaration(
      AstContext astContext, VariableDeclarationList variableDeclarationList);

  Future executeVariableDeclarationAsync(
      AstContext astContext, VariableDeclarationList variableDeclarationList);
}
