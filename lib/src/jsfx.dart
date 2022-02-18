import 'dart:js';

import 'dartfx_main.dart';
import 'util/jsvalue2dart.dart';

void main() {
  context['jsfx'] = jsfx;
  context['jsfxWithEnvs'] = jsfxWithEnvs;
  context['jsfxAssignment'] = jsfxAssignment;
  context['jsSetFunctionResolver'] = jsSetFunctionResolver;
}

dynamic jsSetFunctionResolver(JsFunction jsFunction) {
  fxSetFunctionResolver((name, arguments) {
    return jsFunction.apply([name, ...arguments]);
  });
}

dynamic jsfx(String expression, [JsFunction? onGetEnvValue]) {
  return fx(expression,
      onGetEnvValue: onGetEnvValue == null
          ? null
          : (envVar) {
              return onGetEnvValue.apply([envVar]);
            });
}

dynamic jsfxWithEnvs(String expression, JsObject envValues) {
  var envsMap = jsValueToDart(envValues);
  if (envsMap is Map) {
    return fxWithEnvs(expression, envsMap);
  } else {
    return null;
  }
}

dynamic jsfxAssignment(String expression, JsObject envValues) {
  var envsMap = jsValueToDart(envValues);

  if (envsMap is Map) {
    var obj = envValues;
    var valueKey = "";
    var rightValue = fxAssignment(expression, envsMap, leftEnvs: (envFields) {
      for (var i = 0; i < envFields.length - 1; i++) {
        obj = obj[envFields[i]];
      }

      valueKey = envFields.last;
    });
    obj[valueKey] = rightValue;
    return rightValue;
  }
}
