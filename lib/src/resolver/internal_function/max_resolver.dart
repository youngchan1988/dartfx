// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncMaxResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'MAX';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      double result = double.negativeInfinity;
      for (var arg in arguments!) {
        var value = executor.execute(astContext, arg);
        if (value is num) {
          result = result > value.toDouble() ? result : value.toDouble();
        } else {
          throw 'Function MAX must have numeric arguments';
        }
      }
      return result;
    } else {
      throw 'Function MAX invalid arguments';
    }
  }
}
