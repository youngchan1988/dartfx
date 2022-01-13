///
/// Author: YoungChan
/// Date: 2022-01-12 18:54:14
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-12 18:54:14
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///
import 'dart:js';

/// Converts the specified JavaScript [value] to a Dart instance.
dynamic jsValueToDart(value) {
  // Value types.
  if (value == null) return null;
  if (value is bool || value is num || value is DateTime || value is String)
    return value;

  // JsArray.
  if (value is Iterable) return value.map(jsValueToDart).toList();

  // JsObject.
  return Map.fromIterable(getKeysOfObject(value),
      value: (key) => jsValueToDart(value[key]));
}

// dynamic dartValueToJs(value) {
//   if (value == null) return null;
//   if (value is bool || value is num || value is DateTime || value is String)
//     return value;
//   if (value is Iterable) return value.map(dartValueToJs).toList();

//   if (value is Map) {
//     var obj = JsObject();
//   }
//   return null;
// }

/// Gets the enumerable properties of the specified JavaScript [object].
List<String> getKeysOfObject(JsObject object) =>
    (context['Object'] as JsFunction).callMethod('keys', [object]);
