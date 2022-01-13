import 'dart:js';

import 'package:dartfx/dartfx.dart';
import 'dart:js' as js;
import 'jsvalue2dart.dart';

void main() {
  js.context['jsfx'] = fx;
  js.context['jsfxWithEnvs'] = jsfxWithEnvs;
  js.context['jsfxAssignment'] = jsfxAssignment;
}

dynamic jsfxWithEnvs(String expression, JsObject envs) {
  var envsMap = jsValueToDart(envs);
  if (envsMap is Map) {
    return fxWithEnvs(expression, envsMap);
  } else {
    return null;
  }
}

dynamic jsfxAssignment(String expression, JsObject envs) {
  var envsMap = jsValueToDart(envs);

  if (envsMap is Map) {
    var obj = envs;
    var valueKey = "";
    var rightValue = fxAssignment(expression, envsMap, leftEnvFields: (fields) {
      for (var i = 0; i < fields.length - 1; i++) {
        obj = obj[fields[i]];
      }

      valueKey = fields.last;
    });
    obj[valueKey] = rightValue;
    return rightValue;
  }
}
