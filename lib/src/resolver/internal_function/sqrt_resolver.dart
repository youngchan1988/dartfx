// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:math' as math;
import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncSqrtResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'SQRT';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var argX = arguments!.first;

      var argXValue = executor.execute(astContext, argX);
      if (argXValue is! num) {
        throw 'Function SQRT must have numeric arguments';
      }
      return math.sqrt(argXValue);
    } else {
      throw 'Function SQRT invalid arguments';
    }
  }
}
