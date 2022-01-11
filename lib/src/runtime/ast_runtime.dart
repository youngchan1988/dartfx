import 'package:dartfx/src/util/logger.dart';

import 'ast_context.dart';
import 'ast_runtime_node.dart';
import 'ast_runtime_executor.dart';

///
/// ProjectName: flutterhot
/// Author: youngchan
/// CreateDate: 2020/12/22 10:36 AM
/// Copyright: ©2020 NEW CORE Technology Co. Ltd. All rights reserved.
/// Description: Runtime 实现
///
///

typedef EnvValue = dynamic Function(String);

///Ast函数定义
class AstFunction {
  String? name;
  FormalParameterList? parameters;
  FunctionBody? body;
  String? returnType;
  AstContext? _context;
  AstRuntimeExecutor _executor;

  AstFunction(this._context, this._executor,
      {this.name, this.parameters, required this.body, this.returnType});

  dynamic call({List? params}) {
    var newContext = AstContext(parent: _context);
    var parameterList = parameters?.parameterList;
    //初始化函数参数
    if (params?.isNotEmpty == true && parameterList?.isNotEmpty == true) {
      //记录外部已经传值的参数
      var usedParam = <String?>[];

      for (var i = 0; i < params!.length; i++) {
        var p = params[i];
        if (p is NamedParameter) {
          newContext.addVariable(p.name, p.value);
          usedParam.add(p.name);
        } else {
          newContext.addVariable(parameterList![i]!.name, params[i]);
        }
      }
      for (var p in parameterList!) {
        //如果某些参数没有外部传参，需要将这些参数添加到AstContext中，只针对Named 情况
        if (p!.isNamed! && !usedParam.contains(p.name)) {
          if (p is DefaultFormalParameter) {
            //设置默认参数值
            newContext.addVariable(
                p.name, _executor.execute(newContext, p.defaultValue));
          } else {
            //设置空参数
            newContext.addVariable(p.name, null);
          }
        }
      }
    }
    if (body!.isAsynchronous!) {
      if (body is BlockFunctionBody) {
        return _executor.executeBlockFunctionBodyAsync(
            newContext, body as BlockFunctionBody?);
      } else if (body is ExpressionFunctionBody) {
        return _executor.executeExpressionFunctionBodyAsync(
            newContext, body as ExpressionFunctionBody?);
      }
      return Future.value();
    } else {
      if (body is BlockFunctionBody) {
        return _executor.executeBlockFunctionBody(
            newContext, body as BlockFunctionBody?);
      } else if (body is ExpressionFunctionBody) {
        return _executor.executeExpressionFunctionBody(
            newContext, body as ExpressionFunctionBody?);
      }
    }
  }

  static AstFunction? fromAstNode(AstContext? astContext,
      AstRuntimeExecutor executor, AstRuntimeNode? astNode) {
    if (astNode != null) {
      if (astNode is FunctionDeclaration) {
        return AstFunction(
          astContext,
          executor,
          name: astNode.name,
          parameters: astNode.expression?.parameterList,
          body: astNode.expression?.body,
          returnType: astNode.returnType?.name,
        );
      } else if (astNode is MethodDeclaration) {
        return AstFunction(
          astContext,
          executor,
          name: astNode.name,
          parameters: astNode.parameterList,
          body: astNode.body,
          returnType: astNode.returnType?.name,
        );
      } else if (astNode is FunctionExpression) {
        return AstFunction(
          astContext,
          executor,
          parameters: astNode.parameterList,
          body: astNode.body,
        );
      } else if (astNode is PrefixExpression) {
        if (astNode.argument is PropertyAccess) {
          var propAccess = astNode.argument as PropertyAccess;
          var astFunction = astContext?.findVariable(propAccess.name)?.value;
          return astFunction;
        }
        return executor.execute(astContext, astNode);
      }
    }

    return null;
  }

  static AstFunction? fromAst(
      AstContext astContext, AstRuntimeExecutor executor, Map? ast) {
    if (ast != null) {
      return AstFunction.fromAstNode(
          astContext, executor, AstRuntimeNodeParser.fromAst(ast));
    }
    return null;
  }
}

//可选参数定义
class NamedParameter {
  final String? name;
  final dynamic value;

  NamedParameter({this.name, this.value});
}

//返回值结构
class ReturnValue {
  final dynamic value;
  ReturnValue(this.value);
}

class DefaultAstRuntimeExecutor implements AstRuntimeExecutor {
  DefaultAstRuntimeExecutor({this.envValue});

  final EnvValue? envValue;

  static final _tag = "DefaultAstRuntimeExecutor";

  @override
  dynamic execute(
    AstContext? astContext,
    AstRuntimeNode? astNode,
  ) {
    if (astNode is AsExpression) {
      return executeAsExpression(astContext, astNode);
    } else if (astNode is IsExpression) {
      return executeIsExpression(astContext, astNode);
    } else if (astNode is BinaryExpression) {
      return executeBinaryExpression(astContext, astNode);
    } else if (astNode is Block) {
      return executeBlock(astContext, astNode);
    } else if (astNode is BooleanLiteral) {
      return executeBooleanLiteral(astContext, astNode);
    } else if (astNode is BreakStatement) {
      return astNode;
    } else if (astNode is ConditionalExpression) {
      return executeConditionalExpression(astContext, astNode);
    } else if (astNode is DoubleLiteral) {
      return executeDoubleLiteral(astContext, astNode);
    } else if (astNode is FunctionExpression) {
      return executeFunctionExpression(astContext, astNode);
    } else if (astNode is FunctionExpressionInvocation) {
      return executeFunctionExpressionInvocation(astContext, astNode);
    } else if (astNode is IndexExpression) {
      return executeIndexExpression(astContext, astNode);
    } else if (astNode is InstanceCreationExpression) {
      return executeInstanceCreationExpression(astContext!, astNode);
    } else if (astNode is IntegerLiteral) {
      return executeIntegerLiteral(astContext, astNode);
    } else if (astNode is ListLiteral) {
      return executeListLiteral(astContext, astNode);
    } else if (astNode is MethodInvocation) {
      return executeMethodInvocation(astContext, astNode);
    } else if (astNode is NamedExpression) {
      return executeNamedExpression(astContext, astNode);
    } else if (astNode is NullLiteral) {
      return null;
    } else if (astNode is PrefixExpression) {
      return executePrefixExpression(astContext, astNode);
    } else if (astNode is PrefixedIdentifier) {
      return executePrefixedIdentifier(astContext!, astNode);
    } else if (astNode is PropertyAccess) {
      return executePropertyAccess(astContext, astNode);
    } else if (astNode is ReturnStatement) {
      var value = executeReturnStatement(astContext, astNode);
      return ReturnValue(value);
    } else if (astNode is SetOrMapLiteral) {
      return executeSetOrMapLiteral(astContext, astNode);
    } else if (astNode is SimpleIdentifier) {
      return executeSimpleIdentifier(astContext!, astNode);
    } else if (astNode is StringInterpolation) {
      return executeStringInterpolation(astContext, astNode);
    } else if (astNode is StringLiteral) {
      return executeStringLiteral(astContext, astNode, envValue: envValue);
    } else if (astNode is ThisExpression) {
      return executeThisExpression(astContext!, astNode);
    } else if (astNode is VariableDeclarationList) {
      return executeVariableDeclaration(astContext!, astNode);
    } else if (astNode is AssignmentExpression) {
      executeAssignmentExpression(astContext, astNode);
    } else if (astNode is IfStatement) {
      return executeIfStatement(astContext, astNode);
    } else if (astNode is ForStatement) {
      return executeForStatement(astContext, astNode);
    } else if (astNode is ExpressionStatement) {
      return executeExpressionStatement(astContext, astNode);
    } else if (astNode is SwitchStatement) {
      return executeSwitchStatement(astContext, astNode);
    }
  }

  //执行异步方法
  Future _executeNodeAsync(
      AstContext astContext, AstRuntimeNode? astNode) async {
    if (astNode is VariableDeclarationList) {
      return executeVariableDeclarationAsync(astContext, astNode);
    } else if (astNode is AssignmentExpression) {
      return executeAssignmentExpressionAsync(astContext, astNode);
    } else if (astNode is IfStatement) {
      return executeIfStatementAsync(astContext, astNode);
    } else if (astNode is ForStatement) {
      return executeForStatementAsync(astContext, astNode);
    } else if (astNode is ExpressionStatement) {
      return _executeNodeAsync(astContext, astNode.expression);
    } else if (astNode is SwitchStatement) {
      return executeSwitchStatementAsync(astContext, astNode);
    } else if (astNode is AwaitExpression) {
      await _executeNodeAsync(astContext, astNode.expression);
    } else {
      var value = execute(astContext, astNode);
      if (value is Future) {
        return value;
      } else {
        return Future.value(value);
      }
    }
  }

  @override
  dynamic executeAsExpression(AstContext? astContext, AsExpression expression) {
    return execute(astContext, expression.expression);
  }

  @override
  dynamic executeIsExpression(AstContext? astContext, IsExpression expression) {
    var target = execute(astContext, expression.expression);
    if (expression.notOperator) {
      switch (expression.typeAnnotation) {
        case 'String':
          return target is! String;
        case 'double':
          return target is! double;
        case 'int':
          return target is! int;
        case 'num':
          return target is! num;
        case 'bool':
          return target is! bool;
        case 'Map':
          return target is Map;
        case 'List':
          return target is List;
      }
    } else {
      switch (expression.typeAnnotation) {
        case 'String':
          return target is String;
        case 'double':
          return target is double;
        case 'int':
          return target is int;
        case 'num':
          return target is num;
        case 'bool':
          return target is bool;
        case 'Map':
          return target is Map;
        case 'List':
          return target is List;
      }
    }
    return false;
  }

  @override
  dynamic executeBinaryExpression(
      AstContext? astContext, BinaryExpression expression) {
    //获取左操作符的值
    var leftValue = execute(astContext, expression.left);

    //操作符
    switch (expression.operator) {
      case '+':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue + rightValue;
      case '-':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue - rightValue;
      case '*':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue * rightValue;
      case '/':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue / rightValue;
      case '<':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue < rightValue;
      case '>':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue > rightValue;
      case '<=':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue <= rightValue;
      case '>=':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue >= rightValue;
      case '==':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue == rightValue;
      case '!=':
        //获取右操作符的值
        var rightValue = execute(astContext, expression.right);

        return leftValue != rightValue;
      case '&&':
        //'&&' 操作顺序从前往后判断
        if (leftValue == true) {
          //获取右操作符的值
          var rightValue = execute(astContext, expression.right);
          return rightValue;
        } else {
          return false;
        }
      case '||':
        //或'||'操作顺序从前往后判断
        if (leftValue == true) {
          return true;
        } else {
          //获取右操作符的值
          var rightValue = execute(astContext, expression.right);
          return rightValue;
        }
      case '%':
        var rightValue = execute(astContext, expression.right);
        return leftValue % rightValue;
      case '<<':
        var rightValue = execute(astContext, expression.right);
        return leftValue << rightValue;
      case '|':
        var rightValue = execute(astContext, expression.right);
        return leftValue | rightValue;
      case '&':
        var rightValue = execute(astContext, expression.right);
        return leftValue & rightValue;
      case '>>':
        var rightValue = execute(astContext, expression.right);
        return leftValue >> rightValue;
      case '??':
        //'??' 操作顺序从前往后判断
        if (leftValue == null) {
          var rightValue = execute(astContext, expression.right);
          return rightValue;
        } else {
          return leftValue;
        }
      case '~/':
        var rightValue = execute(astContext, expression.right);
        return leftValue ~/ rightValue;
      default:
        logError(_tag,
            "Undefined BinaryExpression operator: ${expression.operator}");

        return null;
    }
  }

  @override
  dynamic executeBlock(AstContext? astContext, Block block) {
    if (block.body.isNotEmpty == true) {
      //进入代码块时需要New 一个context 节点
      var newContext = AstContext(parent: astContext);
      for (var body in block.body) {
        if (body is BreakStatement) {
          return body;
        }
        var result = execute(newContext, body);
        if (result is ReturnValue) {
          //如果是Return 语法，则直接返回
          return result;
        }
      }
    }
  }

  @override
  Future executeBlockAsync(AstContext astContext, Block block) async {
    if (block.body.isNotEmpty == true) {
      //进入代码块时需要New 一个context 节点
      var newContext = AstContext(parent: astContext);
      for (var body in block.body) {
        if (body is BreakStatement) {
          return Future.value(body);
        }
        var result = await _executeNodeAsync(newContext, body);
        if (result is ReturnValue) {
          //如果是Return 语法，直接返回
          return Future.value(result);
        }
      }
    }
  }

  @override
  dynamic executeBooleanLiteral(
      AstContext? astContext, BooleanLiteral booleanLiteral) {
    return booleanLiteral.value;
  }

  @override
  dynamic executeConditionalExpression(
      AstContext? astContext, ConditionalExpression expression) {
    var condition = execute(astContext, expression.condition);
    if (condition == true) {
      return execute(astContext, expression.thenExpression);
    } else {
      return execute(astContext, expression.elseExpression);
    }
  }

  @override
  dynamic executeDoubleLiteral(
      AstContext? astContext, DoubleLiteral doubleLiteral) {
    return doubleLiteral.value;
  }

  @override
  dynamic executeExpressionStatement(
      AstContext? astContext, ExpressionStatement statement) {
    return execute(astContext, statement.expression);
  }

  @override
  dynamic executeFunctionExpression(
      AstContext? astContext, FunctionExpression expression) {
    return AstFunction.fromAstNode(astContext, this, expression);
  }

  @override
  dynamic executeFunctionExpressionInvocation(AstContext? astContext,
      FunctionExpressionInvocation expressionInvocation) {
    var func = AstFunction.fromAstNode(
        astContext, this, expressionInvocation.function);
    var params = [];
    expressionInvocation.argumentList.forEach((element) {
      params.add(execute(astContext, element));
    });
    return func?.call(params: params);
  }

  @override
  dynamic executeIndexExpression(
      AstContext? astContext, IndexExpression expression) {
    var target = execute(astContext, expression.target);
    if (target == null && expression.isNullAware == true) {
      return null;
    }
    var index = execute(astContext, expression.index);
    return target[index];
  }

  @override
  dynamic executeInstanceCreationExpression(
      AstContext astContext, InstanceCreationExpression expression) {
    return astContext.parse(this, expression.callee?.typeName?.name,
        arguments: expression.arguments, property: expression.callee?.name);
  }

  @override
  dynamic executeIntegerLiteral(
      AstContext? astContext, IntegerLiteral integerLiteral) {
    return integerLiteral.value;
  }

  @override
  dynamic executeListLiteral(AstContext? astContext, ListLiteral listLiteral) {
    var list = [];
    listLiteral.elements.forEach((element) {
      list.add(execute(astContext, element));
    });
    return list;
  }

  @override
  dynamic executeMethodInvocation(
      AstContext? astContext, MethodInvocation methodInvocation) {
    var callee = methodInvocation.callee;
    var argumentList = methodInvocation.argumentList;

    if (callee is SimpleIdentifier) {
      var methodName = callee.name;
      var methodFunc = astContext!.findVariable(methodName)?.value;
      if (methodFunc is AstFunction) {
        //初始化方法参数值
        var params = [];
        for (var arg in argumentList) {
          if (arg is NamedExpression) {
            params.add(NamedParameter(
                name: arg.name, value: execute(astContext, arg.expression)));
          } else {
            params.add(execute(astContext, arg));
          }
        }
        return methodFunc.call(params: params);
      } else {
        //调用拓展解析器尝试解析
        return astContext.parse(this, methodName, arguments: argumentList);
      }
    } else if (callee is MemberExpression) {
      if (callee.target == null) {
        logError(_tag,
            "MethodInvocation->callee->MemberExpression->Unknown callee object: null");
        return;
      } else if (callee.target is SuperExpression) {
        //忽略super 调用
        logDebug(_tag, "Ignore super call");
        return;
      } else {
        var realTarget = execute(astContext, callee.target);
        if (realTarget == null) {
          if (callee.target is SimpleIdentifier) {
            //调用拓展解析器尝试解析
            return astContext!.parse(
                this, (callee.target as SimpleIdentifier).name,
                property: callee.property, arguments: argumentList);
          } else {
            return null;
          }
        } else {
          //调用拓展解析器尝试解析
          return astContext!.parse(this, realTarget,
              property: callee.property, arguments: argumentList);
        }
      }
    } else {
      logError(_tag, "MethodInvocation->Unknown: ${callee.toString()}");
    }
  }

  @override
  dynamic executePrefixExpression(
      AstContext? astContext, PrefixExpression expression) {
    var argValue = execute(astContext, expression.argument);
    if ((argValue is int || argValue is double) &&
        (expression.operator == '++' ||
            expression.operator == '--' ||
            expression.operator == '-')) {
      if (expression.operator == "++") {
        astContext!.setVariableValue(
            (expression.argument as SimpleIdentifier).name, argValue + 1);
        if (expression.prefix == true) {
          return ++argValue;
        } else {
          return argValue++;
        }
      } else if (expression.operator == "--") {
        astContext!.setVariableValue(
            (expression.argument as SimpleIdentifier).name, argValue - 1);
        if (expression.prefix == true) {
          return --argValue;
        } else {
          return argValue--;
        }
      } else if (expression.operator == "-" && expression.prefix == true) {
        return -argValue;
      }
    } else if (argValue is bool &&
        expression.operator == '!' &&
        expression.prefix == true) {
      return !argValue;
    } else if (expression.operator == '!' && expression.prefix == false) {
      return argValue!;
    }
  }

  @override
  dynamic executePrefixedIdentifier(
      AstContext astContext, PrefixedIdentifier identifier) {
    var target = astContext.findVariable(identifier.prefix)?.value;
    //调用拓展解析器尝试解析
    if (target != null) {
      return astContext.parse(this, target, property: identifier.identifier);
    } else {
      return astContext.parse(this, identifier.prefix,
          property: identifier.identifier);
    }
  }

  @override
  dynamic executePropertyAccess(
      AstContext? astContext, PropertyAccess propertyAccess) {
    var target = execute(astContext, propertyAccess.expression);
    if (target == null && propertyAccess.isNullAware == true) {
      return null;
    }
    //调用拓展解析器尝试解析
    return astContext!.parse(this, target, property: propertyAccess.name);
  }

  @override
  dynamic executeReturnStatement(
      AstContext? astContext, ReturnStatement returnStatement) {
    return execute(astContext, returnStatement.argument);
  }

  @override
  dynamic executeSetOrMapLiteral(
      AstContext? astContext, SetOrMapLiteral mapLiteral) {
    var mapValue = {};
    mapLiteral.elements.forEach((element) {
      mapValue[element!.key!.value] = execute(astContext, element.value);
    });
    return mapValue;
  }

  @override
  dynamic executeSimpleIdentifier(
      AstContext astContext, SimpleIdentifier identifier) {
    return astContext.findVariable(identifier.name)?.value;
  }

  @override
  dynamic executeStringInterpolation(
      AstContext? astContext, StringInterpolation interpolation) {
    var str = '';
    interpolation.elements.forEach((element) {
      if (element is InterpolationExpression) {
        str += execute(astContext, element.expression)?.toString() ?? "";
      } else if (element is InterpolationString) {
        str += element.value!;
      }
    });
    return str;
  }

  @override
  dynamic executeStringLiteral(
      AstContext? astContext, StringLiteral stringLiteral,
      {EnvValue? envValue}) {
    if (isEnvString(stringLiteral.value.toString()) && envValue != null) {
      return envValue(stringLiteral.value.toString()) ?? '';
    }
    return stringLiteral.value;
  }

  @override
  dynamic executeThisExpression(
      AstContext astContext, ThisExpression expression) {
    return null;
  }

  dynamic _executeAssignment(AstContext? astContext,
      AssignmentExpression expression, dynamic rightValue) {
    var left = expression.left;
    var leftValue = execute(astContext, left);
    if (leftValue != null && rightValue != null) {
      switch (expression.operator) {
        case '+=':
          rightValue = leftValue + rightValue;
          break;
        case '-=':
          rightValue = leftValue - rightValue;
          break;
        case '*=':
          rightValue = leftValue * rightValue;
          break;
        case '/=':
          rightValue = leftValue / rightValue;
          break;
      }
    }

    if (left is SimpleIdentifier) {
      astContext!.setVariableValue(left.name, rightValue);
    } else if (left is PrefixedIdentifier) {
      var target = astContext!.findVariable(left.prefix)?.value;
      logWarn(_tag, 'PrefixedIdentifier is in TODO, target: $target');
    } else if (left is PropertyAccess) {
      var property = left.expression;
      var target = execute(astContext, property);
      logWarn(_tag, 'PropertyAccess is in TODO, target: $target');
    } else if (left is IndexExpression) {
      var target = execute(astContext, left.target);
      if (target != null && !left.isNullAware!) {
        var index = execute(astContext, left.index);
        target[index] = rightValue;
      }
    }
  }

  @override
  dynamic executeAssignmentExpression(
      AstContext? astContext, AssignmentExpression expression) {
    var rightValue = execute(astContext, expression.right);
    _executeAssignment(astContext, expression, rightValue);
  }

  @override
  Future executeAssignmentExpressionAsync(
      AstContext astContext, AssignmentExpression expression) async {
    var rightValue;
    if (expression.right is AwaitExpression &&
        (expression.right as AwaitExpression).expression != null) {
      var result = executeMethodInvocation(
          astContext, (expression.right as AwaitExpression).expression!);
      if (result is Future) {
        rightValue = await result;
        rightValue = await result;
      }
    } else {
      rightValue = execute(astContext, expression.right);
    }
    _executeAssignment(astContext, expression, rightValue);
  }

  @override
  dynamic executeForStatement(AstContext? astContext, ForStatement statement) {
    var forLoopParts = statement.forLoopParts;
    //for...in... 语句处理
    if (forLoopParts?.type == ForLoopParts.forEachPartsWithDeclaration) {
      //获取迭代数据集
      var iterableValue =
          (astContext!.findVariable(forLoopParts!.iterable)?.value ?? [])
              as List;
      if (iterableValue.isNotEmpty == true) {
        for (var item in iterableValue) {
          //将迭代值存入变量栈
          astContext.setVariableValue(forLoopParts.loopVariable, item);
          //执行循环内的逻辑
          if (statement.body != null) {
            var result = executeBlock(astContext, statement.body!);
            if (result is BreakStatement) {
              break;
            } else if (result is ReturnValue) {
              return result;
            }
          } else {
            return null;
          }
        }
      }
    } else {
      //初始化
      if (forLoopParts?.type == ForLoopParts.forPartsWithDeclarations) {
        executeVariableDeclaration(astContext!, forLoopParts!.variableList!);
      } else if (forLoopParts?.type == ForLoopParts.forPartsWithExpression) {
        executeAssignmentExpression(astContext, forLoopParts!.initialization!);
      }

      //循环判断条件位
      bool condition = false;
      if (forLoopParts?.condition != null) {
        condition =
            executeBinaryExpression(astContext, forLoopParts!.condition!);
      }

      while (condition) {
        //执行循环体的逻辑
        if (statement.body != null) {
          var result = executeBlock(astContext, statement.body!);
          if (result is BreakStatement) {
            break;
          } else if (result is ReturnValue) {
            return result;
          }
          //解析循环步长
          if (forLoopParts?.updater is PrefixExpression) {
            executePrefixExpression(
                astContext, forLoopParts!.updater as PrefixExpression);
          } else if (forLoopParts?.updater is AssignmentExpression) {
            executeAssignmentExpression(
                astContext, forLoopParts!.updater as AssignmentExpression);
          }

          //循环判断条件位
          condition =
              executeBinaryExpression(astContext, forLoopParts!.condition!);
        } else {
          return null;
        }
      }
    }
  }

  @override
  Future executeForStatementAsync(
      AstContext astContext, ForStatement statement) async {
    var forLoopParts = statement.forLoopParts;
    //for...in... 语句处理
    if (forLoopParts?.type == ForLoopParts.forEachPartsWithDeclaration) {
      //获取迭代数据集
      var iterableValue =
          (astContext.findVariable(forLoopParts!.iterable)?.value ?? [])
              as List;
      if (iterableValue.isNotEmpty == true) {
        for (var item in iterableValue) {
          //将迭代值存入变量栈
          astContext.setVariableValue(forLoopParts.loopVariable, item);
          //执行循环内的逻辑
          if (statement.body != null) {
            var result = await executeBlockAsync(astContext, statement.body!);
            if (result is BreakStatement) {
              break;
            } else if (result is ReturnValue) {
              return Future.value(result);
            }
          } else {
            return null;
          }
        }
      }
    } else {
      //初始化
      if (forLoopParts?.type == ForLoopParts.forPartsWithDeclarations) {
        executeVariableDeclaration(astContext, forLoopParts!.variableList!);
      } else if (forLoopParts?.type == ForLoopParts.forPartsWithExpression) {
        executeAssignmentExpression(astContext, forLoopParts!.initialization!);
      }
      //循环判断条件位
      bool condition = false;
      if (forLoopParts?.condition != null) {
        condition =
            executeBinaryExpression(astContext, forLoopParts!.condition!);
      }

      while (condition) {
        if (statement.body != null) {
          //执行循环体的逻辑
          var result = await executeBlockAsync(astContext, statement.body!);
          if (result is BreakStatement) {
            break;
          } else if (result is ReturnValue) {
            return Future.value(result);
          }
          //解析循环步长
          if (forLoopParts?.updater is PrefixExpression) {
            executePrefixExpression(
                astContext, forLoopParts?.updater as PrefixExpression);
          } else if (forLoopParts?.updater is AssignmentExpression) {
            await executeAssignmentExpressionAsync(
                astContext, forLoopParts?.updater as AssignmentExpression);
          }

          //循环判断条件位
          condition =
              executeBinaryExpression(astContext, forLoopParts!.condition!);
        } else {
          return null;
        }
      }
    }
  }

  @override
  dynamic executeIfStatement(AstContext? astContext, IfStatement statement) {
    bool condition = execute(astContext, statement.condition) as bool;
    if (condition) {
      return execute(astContext, statement.consequent);
    } else {
      return execute(astContext, statement.alternate);
    }
  }

  @override
  Future executeIfStatementAsync(
      AstContext astContext, IfStatement statement) async {
    bool condition = execute(astContext, statement.condition) as bool;
    if (condition) {
      if (statement.consequent is Block) {
        var result =
            await executeBlockAsync(astContext, statement.consequent as Block);
        return Future.value(result);
      } else if (statement.consequent is AwaitExpression &&
          (statement.consequent as AwaitExpression).expression != null) {
        var result = executeMethodInvocation(
            astContext, (statement.consequent as AwaitExpression).expression!);
        if (result is Future) {
          var value = await result;
          return Future.value(value);
        }
        return result;
      } else {
        return execute(astContext, statement.consequent);
      }
    } else {
      if (statement.alternate is Block) {
        var result =
            await executeBlockAsync(astContext, statement.alternate as Block);
        return Future.value(result);
      } else if (statement.alternate is IfStatement) {
        var result = await executeIfStatementAsync(
            astContext, statement.alternate as IfStatement);
        return Future.value(result);
      } else if (statement.alternate is AwaitExpression &&
          (statement.alternate as AwaitExpression).expression != null) {
        var result = executeMethodInvocation(
            astContext, (statement.alternate as AwaitExpression).expression!);
        if (result is Future) {
          var value = await result;
          return Future.value(value);
        }
        return result;
      } else {
        return execute(astContext, statement.alternate);
      }
    }
  }

  @override
  dynamic executeSwitchStatement(
      AstContext? astContext, SwitchStatement statement) {
    var conditionValue = execute(astContext, statement.checkValue);

    for (var c in statement.body) {
      if (c.isDefault || conditionValue == execute(astContext, c.condition)) {
        for (var b in c.statements) {
          if (b is BreakStatement) {
            break;
          } else {
            execute(astContext, b);
          }
        }
        break;
      }
    }
  }

  @override
  Future executeSwitchStatementAsync(
      AstContext astContext, SwitchStatement statement) async {
    var conditionValue = execute(astContext, statement.checkValue);

    for (var c in statement.body) {
      if (c.isDefault || conditionValue == execute(astContext, c.condition)) {
        for (var b in c.statements) {
          if (b is BreakStatement) {
            break;
          } else if (b is Block) {
            var result = await executeBlockAsync(astContext, b);
            if (result is ReturnValue) {
              return Future.value(result);
            }
          } else if (b is AwaitExpression && b.expression != null) {
            var result = executeMethodInvocation(astContext, b.expression!);
            if (result is Future) {
              await result;
            }
          } else {
            execute(astContext, b);
          }
        }
        break;
      }
    }
  }

  @override
  dynamic executeVariableDeclaration(
      AstContext astContext, VariableDeclarationList variableDeclarationList) {
    var variableDeclarator = variableDeclarationList.declarationList[0];
    var value = variableDeclarator.init == null
        ? null
        : execute(astContext, variableDeclarator.init);
    //存入声明的初始化变量值
    astContext.addVariable(variableDeclarator.name, value);
  }

  @override
  Future executeVariableDeclarationAsync(AstContext astContext,
      VariableDeclarationList variableDeclarationList) async {
    var variableDeclarator = variableDeclarationList.declarationList[0];
    var value;
    if (variableDeclarator.init != null) {
      if (variableDeclarator.init is AwaitExpression &&
          (variableDeclarator.init as AwaitExpression).expression != null) {
        var result = executeMethodInvocation(astContext,
            (variableDeclarator.init as AwaitExpression).expression!);
        if (result is Future) {
          value = await result;
        }
      } else {
        value = execute(astContext, variableDeclarator.init);
      }
    }
    //存入声明的初始化变量值
    astContext.addVariable(variableDeclarator.name, value);
  }

  @override
  dynamic executeBlockFunctionBody(
      AstContext? astContext, BlockFunctionBody? functionBody) {
    var result = execute(astContext, functionBody!.block);
    if (result is ReturnValue) {
      return result.value;
    }
    return result;
  }

  @override
  Future executeBlockFunctionBodyAsync(
      AstContext astContext, BlockFunctionBody? functionBody) async {
    if (functionBody?.block != null) {
      var result = await executeBlockAsync(astContext, functionBody!.block!);
      if (result is ReturnValue) {
        return Future.value(result.value);
      }
      return Future.value(result);
    } else {
      return Future.value();
    }
  }

  @override
  dynamic executeExpressionFunctionBody(
      AstContext astContext, ExpressionFunctionBody? functionBody) {
    var result = execute(astContext, functionBody!.expression);
    if (result is ReturnValue) {
      return result.value;
    }
    return result;
  }

  @override
  dynamic executeExpressionFunctionBodyAsync(
      AstContext astContext, ExpressionFunctionBody? functionBody) async {
    var result =
        await executeBlockAsync(astContext, functionBody!.expression as Block);
    if (result is ReturnValue) {
      return Future.value(result.value);
    }
    return Future.value(result);
  }

  @override
  NamedParameter executeNamedExpression(
      AstContext? astContext, NamedExpression expression) {
    var value = execute(astContext, expression.expression);
    return NamedParameter(name: expression.name, value: value);
  }

  bool isEnvString(String value) {
    if (value.length > 2 &&
        value.indexOf("\$") == 0 &&
        value.lastIndexOf("\$") == value.length - 1) {
      return true;
    } else {
      return false;
    }
  }
}
