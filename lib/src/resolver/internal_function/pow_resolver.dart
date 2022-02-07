// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:math' as math;
import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncPowResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'POW';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if ((arguments?.length ?? 0) >= 2) {
      var argX = arguments!.first;
      var argExp = arguments[1];
      var argXValue = executor.execute(astContext, argX);
      if (argXValue is! num) {
        throw 'Function POW must have numeric arguments';
      }
      var argExpValue = executor.execute(astContext, argExp);
      if (argExpValue is! num) {
        throw 'Function POW must have numeric arguments';
      }
      return math.pow(argXValue, argExpValue);
    } else {
      throw 'Function POW invalid arguments';
    }
  }
}
