// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';

class FuncIntfloorResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'INTFLOOR';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.isNotEmpty == true) {
      var arg = arguments!.first;
      var value = executor.execute(astContext, arg);
      if (value is num) {
        return value.floor();
      } else {
        throw 'Function INTFLOOR must have a numeric argument';
      }
    } else {
      throw 'Function INTFLOOR invalid arguments';
    }
  }
}
