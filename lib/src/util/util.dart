///
/// Author: YoungChan
/// Date: 2022-01-13 13:08:04
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-13 13:09:39
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

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
