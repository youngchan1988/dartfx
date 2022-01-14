// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/util.dart';

class FuncRoundResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'ROUND';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var argNumber = arguments!.first;
      var argDigit = arguments[1];
      var numberValue = executor.execute(astContext, argNumber);
      var digitValue = executor.execute(astContext, argDigit);
      if (numberValue is num && digitValue is int) {
        if (numberValue is double) {
          return double.tryParse(formatNum(numberValue, digits: digitValue)) ??
              numberValue;
        } else {
          return numberValue;
        }
      } else {
        throw 'Function ROUND must have numeric arguments';
      }
    } else {
      throw 'Function ROUND invalid arguments';
    }
  }
}
