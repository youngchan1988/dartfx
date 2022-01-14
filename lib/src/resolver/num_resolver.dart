// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class IntResolver extends AstResolver {
  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target is int) {
      switch (property) {
        case 'toString':
          return target.toString();
        case 'toDouble':
          return target.toDouble();
      }
    }
    return target;
  }

  @override
  bool canResolve(target, {String? property}) {
    return target is int;
  }
}

///double 解析
///* double.maxFinite
///* double.infinity
///* double.minPositive
///* double.negativeInfinity
///* double.nan
///* toString
///* toInt
///* toDouble
class DoubleResolver extends AstResolver {
  @override
  dynamic resolve(
    AstContext astContext,
    AstRuntimeExecutor executor,
    target, {
    String? property,
    List<AstRuntimeNode?>? arguments,
  }) {
    if (target == "double") {
      switch (property) {
        case "maxFinite":
          return double.maxFinite;
        case "infinity":
          return double.infinity;
        case "minPositive":
          return double.minPositive;
        case "negativeInfinity":
          return double.negativeInfinity;
        case "nan":
          return double.nan;
      }
    } else if (target is double) {
      switch (property) {
        case 'toString':
          return target.toString();
        case 'toInt':
          return target.toInt();
        case "toDouble":
          return target.toDouble();
      }
    }
    return target;
  }

  @override
  bool canResolve(target, {String? property}) =>
      target == "double" || target is double;
}
