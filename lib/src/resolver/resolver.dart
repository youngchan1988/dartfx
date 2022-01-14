// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

import 'map_resolver.dart';
import 'iterable_resolver.dart';
import 'list_resolver.dart';
import 'num_resolver.dart';
import 'string_resolver.dart';
import 'internal_function/average_resolver.dart';
import 'internal_function/sum_resolver.dart';
import 'internal_function/max_resolver.dart';
import 'internal_function/min_resolver.dart';
import 'internal_function/abs_resolver.dart';
import 'internal_function/round_resolver.dart';
import 'internal_function/fixed_resolver.dart';
import 'internal_function/intfloor_resolver.dart';
import 'internal_function/intceil_resolver.dart';
import 'internal_function/value_resolver.dart';
import 'internal_function/timestamp_resolver.dart';
import 'internal_function/timeformat_resolver.dart';
import 'internal_function/isempty_resolver.dart';
import 'internal_function/substring_resolver.dart';
import 'internal_function/replacestring_resolver.dart';
import 'internal_function/regmatch_resolver.dart';

typedef FunctionResolver = dynamic Function(
    String functionName, List arguments);

class Resolver extends AstResolver {
  Resolver() {
    //初始化Parser map
    addResolver(StringResolver())
        .addResolver(IntResolver())
        .addResolver(DoubleResolver())
        .addResolver(ListResolver())
        .addResolver(MapResolver())
        .addResolver(IterableResolver())
        .addResolver(FuncSumResolver())
        .addResolver(FuncAverageResolver())
        .addResolver(FuncMaxResolver())
        .addResolver(FuncMinResolver())
        .addResolver(FuncAbsResolver())
        .addResolver(FuncRoundResolver())
        .addResolver(FuncFixedResolver())
        .addResolver(FuncIntfloorResolver())
        .addResolver(FuncIntceilResolver())
        .addResolver(FuncValueResolver())
        .addResolver(FuncTimestampResolver())
        .addResolver(FuncTimeFormatResolver())
        .addResolver(FuncIsEmptyResolver())
        .addResolver(FuncSubstringResolver())
        .addResolver(FuncReplaceStringResolver())
        .addResolver(FuncRegmatchResolver());
  }

  static const _tag = "CommonParser";

  static Resolver get instance => _instance ??= Resolver();

  static Resolver? _instance;

  FunctionResolver? functionApply;

  final _resolverList = <AstResolver>[];

  Resolver addResolver(AstResolver resolver) {
    _resolverList.add(resolver);
    return this;
  }

  @override
  bool canResolve(target, {String? property}) => true;

  ///
  /// ClassName.methodName()
  /// methodName()
  /// obj.methodName()
  /// ClassName()
  ///
  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    for (var resolver in _resolverList) {
      if (resolver.canResolve(target, property: property)) {
        return resolver.resolve(astContext, executor, target,
            property: property, arguments: arguments);
      }
    }
    if (functionApply != null && target is String && property == null) {
      var argumentsValue = [];
      if (arguments != null) {
        for (var arg in arguments) {
          argumentsValue.add(executor.execute(astContext, arg));
        }
      }
      return functionApply!(target, argumentsValue);
    }
    warn(
        object: this,
        message:
            "No default resolver for target: $target, or property: $property");
  }
}
