// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncSubstringResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'SUBSTRING';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if ((arguments?.length ?? 0) > 1) {
      var strArg = arguments!.first;
      var startArg = arguments[1];
      var strValue = executor.execute(astContext, strArg);
      var startValue = executor.execute(astContext, startArg);
      if (strValue is! String || startValue is! int) {
        throw 'Function SUBSTRING invalid argument type';
      }
      int end = strValue.length;
      if (arguments.length > 2) {
        var lenValue = executor.execute(astContext, arguments[2]);
        if (lenValue is int) {
          end = startValue + lenValue;
        } else {
          throw 'Function SUBSTRING invalid argument type';
        }
      }
      return strValue.substring(startValue, end);
    } else {
      throw 'Function SUBSTRING invalid arguments';
    }
  }
}
