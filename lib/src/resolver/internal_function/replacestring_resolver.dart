// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncReplaceStringResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'REPLACESTRING';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 3) {
      var sourceArg = arguments!.first;
      var oldArg = arguments[1];
      var newArg = arguments[2];
      var sourceValue = executor.execute(astContext, sourceArg);
      var oldValue = executor.execute(astContext, oldArg);
      var newValue = executor.execute(astContext, newArg);
      if (sourceValue is String && oldValue is String && newValue is String) {
        return sourceValue.replaceAll(oldValue, newValue);
      } else {
        throw 'Function REPLACESTRING must have three string arguments';
      }
    } else {
      throw 'Function REPLACESTRING invalid arguments';
    }
  }
}
