// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///格式化数字
String formatNum(num? value,
    {int digits = 2, bool autoSplitByThousand = false}) {
  if (value == null) {
    return '0';
  }
  if (value.isInfinite) {
    return value.toStringAsFixed(digits);
  } else {
    if (digits == 0) {
      return value.toStringAsFixed(0);
    }
    var s = value.toDouble().toString();
    var dotIndex = s.indexOf('.');
    var dotS = s.substring(dotIndex + 1);

    if ((dotS.length) > digits) {
      var s = value.toStringAsFixed(digits);
      var n = num.tryParse(s);
      if (n == null) {
        return s;
      } else {
        return formatNum(n, digits: digits);
      }
    } else {
      var result = value.truncateToDouble() == value
          ? value.toStringAsFixed(0)
          : value.toString();
      return result;
    }
  }
}
