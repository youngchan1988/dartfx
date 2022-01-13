///
///Author: YoungChan
///Date: 2020-04-23 16:05:10
///LastEditors: YoungChan
///LastEditTime: 2020-10-29 14:01:00
///Description: file content
///

import 'package:dartfx/src/resolver/resolver.dart';

import 'ast_resolver.dart';
import 'ast_runtime_node.dart';
import 'ast_runtime_executor.dart';

class AstContext {
  AstContext? parent;

  ///变量集
  Map<String?, AstReferenceVariable> _variables = {};

  ///引用的Ast数据， <String(astId), Map(ast)>
  Map<String, Map?> _referenceAst = {};

  Map<String, Map?> get referenceAst => _referenceAst;

  ///解析器集合
  List<AstResolver?> _parserList = [];

  List<AstResolver?> get parserList => _parserList;

  AstContext({this.parent}) {
    if (parent != null) {
      _referenceAst.addAll(parent!.referenceAst);
      _parserList.addAll(parent!.parserList);
    }
  }

  void dispose() {
    _variables.clear();
    parent = null;
  }

  ///解析表达式
  dynamic resolve(
    AstRuntimeExecutor executor,
    dynamic target, {
    String? property,
    List<AstRuntimeNode>? arguments,
  }) {
    ///优先执行当前Context中注册的解析器
    for (int i = _parserList.length - 1; i >= 0; i--) {
      var parser = _parserList[i]!;
      if (parser.canResolve(target, property: property)) {
        return parser.resolve(this, executor, target,
            property: property, arguments: arguments);
      }
    }

    ///如果没有匹配解析器，执行默认解析器
    return Resolver.instance!.resolve(this, executor, target,
        property: property, arguments: arguments);
  }

  ///添加自定义parser，后添加的parser将优先处理，对于相同事件/属性的情况，后添加的parser将覆盖前面的parser
  void addParser(AstResolver? parser) {
    if (!_parserList.contains(parser)) {
      _parserList.add(parser);
    }
  }

  ///查找变量
  AstReferenceVariable? findVariable(String? variableName) {
    var ref = _variables[variableName];
    if (ref != null) {
      return ref;
    }
    //如果当前作用域没有匹配变量，向上追溯查找变量
    if (parent != null) {
      ref = parent!.findVariable(variableName);
    }
    return ref;
  }

  ///添加变量
  AstReferenceVariable addVariable(
      String? variableName, dynamic variableValue) {
    var ref = AstReferenceVariable(variableValue);
    _variables[variableName] = ref;
    return ref;
  }

  ///设置变量值
  void setVariableValue(String? variableName, dynamic variableValue) {
    var ref = _variables[variableName];
    if (ref == null) {
      //向上追溯查找变量
      if (parent != null) {
        ref = parent!.findVariable(variableName);
      }
      if (ref != null) {
        //更新变量值
        ref.value = variableValue;
      } else {
        //在当前作用域中添加该变量
        _variables[variableName] = AstReferenceVariable(variableValue);
      }
    } else {
      //更新变量值
      ref.value = variableValue;
    }
  }
}

///模拟引用变量
class AstReferenceVariable {
  dynamic value;
  AstReferenceVariable(this.value);
}
