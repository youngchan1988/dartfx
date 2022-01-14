// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncRegmatchResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'REGMATCH';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var sourceArg = arguments!.first;
      var regArg = arguments[1];
      var sourceValue = executor.execute(astContext, sourceArg);
      var regValue = executor.execute(astContext, regArg);
      if (sourceValue is String && regValue is String) {
        var regExp = RegExp(regValue);
        return regExp.hasMatch(sourceValue);
      } else {
        throw 'Function REGMATCH must have two string arguments';
      }
    } else {
      throw 'Function REGMATCH invalid arguments';
    }
  }
}
