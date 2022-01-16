// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
