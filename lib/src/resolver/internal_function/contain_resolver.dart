// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncContainResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'CONTAIN';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if ((arguments?.length ?? 0) >= 2) {
      var argList = arguments!.first;
      var argSub = arguments[1];
      var argListValue = executor.execute(astContext, argList);
      if (argListValue is! List) {
        throw 'Function CONTAIN must be List arguments';
      }
      var argSubValue = executor.execute(astContext, argSub);
      if (argSubValue is! List) {
        throw 'Function CONTAIN must be List arguments';
      }
      var result = true;
      for (var n in argSubValue) {
        if (!argListValue.contains(n)) {
          result = false;
          break;
        }
      }
      return result;
    } else {
      throw 'Function CONTAIN invalid arguments';
    }
  }
}
