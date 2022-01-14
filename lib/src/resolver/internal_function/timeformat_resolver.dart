// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:intl/intl.dart';

class FuncTimeFormatResolver extends AstResolver {
  @override
  bool canResolve(target, {String? property}) => target == 'TIMEFORMAT';

  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    if (arguments?.length == 2) {
      var dateArg = arguments!.first;
      var patternArg = arguments[1];
      var dateValue = executor.execute(astContext, dateArg);
      var patternValue = executor.execute(astContext, patternArg);
      if (dateValue is int && patternValue is String) {
        var format = DateFormat(patternValue);
        return format.format(DateTime.fromMillisecondsSinceEpoch(dateValue));
      } else {
        throw 'Function TIMEFORMAT must have a integer argument and a String argument';
      }
    } else {
      throw 'Function TIMEFORMAT invalid arguments';
    }
  }
}
