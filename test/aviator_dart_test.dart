// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/dartfx.dart';
import 'package:test/test.dart';

void main() {
  group('Test binary expression', () {
    test('Test arithmetic', () {
      var result = fx('1+(2+3)*7 - 4/2');
      expect(result, 34);
    });

    test('Test remainder', () {
      var result = fx('9%4');
      expect(result, 1);
    });

    test('Test divide to integer', () {
      var result = fx('9~/4');
      expect(result, 2);
    });

    test('Test negative', () {
      var result = fx('-3+9');
      expect(result, 6);
    });

    test('Test great', () {
      var result = fx('3>0 && 3>=3');
      expect(result, true);
    });

    test('Test less', () {
      var result = fx('3<0 && 3<=3');
      expect(result, false);
    });

    test('Test equal', () {
      var result = fx('3==3');
      expect(result, true);
    });

    test('Test not equal', () {
      var result = fx('3!=3');
      expect(result, false);
    });

    test('Test and or not', () {
      var result = fx('(3>0 && 3>1) || !(0<-1)');
      expect(result, true);
    });
    test('Test and calc', () {
      var result = fx('0x22 & 0x07');
      expect(result, 0x02);
    });

    test('Test or calc', () {
      var result = fx('0x22 | 0x05');
      expect(result, 0x27);
    });

    test('Test not calc', () {
      var result = fx('~0x22&0xFF');
      expect(result, 0xDD);
    });

    test('Test not or calc', () {
      var result = fx('0x22 ^ 0x07');
      expect(result, 0x25);
    });

    test('Test left move', () {
      var result = fx('0x22 << 2');
      expect(result, 0x88);
    });

    test('Test right move', () {
      var result = fx('0x22 >> 1');
      expect(result, 0x11);
    });
  });
  group('Test grammar', () {
    test('Test condition', () {
      var result = fx('3>0 && 1<3 ? "yes": "no"');
      expect(result, "yes");
    });
  });

  group('Test env variable', () {
    test('Test env value', () {
      var envs = {
        "43858": {"message": "单位"},
        "43859": {"currency": "100", "unitName": "人民币"}
      };
      var result = fxWithEnvs('\$43859.currency\$+\$43859.unitName\$', envs);
      expect(result, "100人民币");
    });
  });

  group('Test assignment', () {
    test('Test env assignment', () {
      var envs = {
        "43858": {"message": "单位"},
        "43859": {"currency": "100", "unitName": "人民币"}
      };
      fxAssignment(
          '\$43858.message\$=\$43859.currency\$+\$43859.unitName\$', envs);
      expect(envs["43858"]!["message"], "100人民币");
    });

    test('Test +=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$+=\$43859.currency\$', envs);
      expect(envs["43858"]!["number"], 200);
    });

    test('Test -=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$-=\$43859.currency\$', envs);
      expect(envs["43858"]!["number"], 0);
    });

    test('Test *=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$*=\$43859.currency\$', envs);
      expect(envs["43858"]!["number"], 10000);
    });

    test('Test %=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$%=8', envs);
      expect(envs["43858"]!["number"], 4);
    });

    test('Test &=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$&=0x07', envs);
      expect(envs["43858"]!["number"], 4);
    });

    test('Test |=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$|=0x07', envs);
      expect(envs["43858"]!["number"], 103);
    });

    test('Test ^=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$^=0x07', envs);
      expect(envs["43858"]!["number"], 99);
    });

    test('Test >>=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$>>=2', envs);
      expect(envs["43858"]!["number"], 25);
    });

    test('Test <<=', () {
      var envs = {
        "43858": {"number": 100},
        "43859": {"currency": 100, "unitName": "人民币"}
      };
      fxAssignment('\$43858.number\$<<=2', envs);
      expect(envs["43858"]!["number"], 400);
    });
  });

  group('Test internal function', () {
    test('Test SUM', () {
      var envs = {
        "column": [1, 2, 0.3, 4.5, 6]
      };
      var result = fxWithEnvs('SUM(\$column\$)', envs);
      expect(result, 13.8);
    });

    test('Test AVERAGE', () {
      var envs = {
        "column": [1, 2, 3, 4, 6]
      };
      var result = fxWithEnvs('AVERAGE(\$column\$)', envs);
      expect(result, 3.2);
    });

    test('Test MAX', () {
      var result = fx('MAX(1, 2, 6, 4, 5.2)');
      expect(result, 6);

      result = fx('MAX(-1, -2, -6, -4, -5.2)');
      expect(result, -1);
    });

    test('Test MIN', () {
      var result = fx('MIN(1, 2, 6, 4, 5.2)');
      expect(result, 1);

      result = fx('MIN(-1, -2, 6, -4, -5.2)');
      expect(result, -5.2);
    });

    test('Test ABS', () {
      var result = fx('ABS(10)');
      expect(result, 10);

      result = fx('ABS(-10)');
      expect(result, 10);
    });

    test('Test ROUND', () {
      var result = fx('ROUND(123.45643234, 3)');
      expect(result, 123.456);
    });

    test('Test FIXED', () {
      var result = fx('FIXED(123.45643234, 2)');
      expect(result, "123.46");
    });

    test('Test INTFLOOR', () {
      var result = fx('INTFLOOR(123.66)');
      expect(result, 123);
    });

    test('Test INTCEIL', () {
      var result = fx('INTCEIL(123.12)');
      expect(result, 124);
    });

    test('Test VALUE', () {
      var result = fx('VALUE("100")');
      expect(result, 100);

      result = fx('VALUE("100.23")');
      expect(result, 100.23);
    });

    test('Test TIMESTAMP', () {
      var result =
          fx('TIMESTAMP("2022/01/13 20:13:22", "yyyy/MM/dd HH:mm:ss")');
      var dateTime = DateTime.fromMillisecondsSinceEpoch(result);
      expect(dateTime.year, 2022);
      expect(dateTime.month, 1);
      expect(dateTime.day, 13);
      expect(dateTime.hour, 20);
      expect(dateTime.minute, 13);
      expect(dateTime.second, 22);
    });

    test('Test TIMEFORMAT', () {
      var result = fx('TIMEFORMAT(1642059246000, "yyyy/MM/dd HH:mm:ss")');
      expect(result, "2022/01/13 15:34:06");
    });

    test('Test ISEMPTY', () {
      var result = fx('ISEMPTY("hello")');
      expect(result, false);

      result = fx('ISEMPTY("")');
      expect(result, true);

      var listEnvs = {
        "column": [1, 2, 0.3, 4.5, 6],
        "row": [],
      };
      result = fxWithEnvs('ISEMPTY(\$column\$)', listEnvs);
      expect(result, false);
      result = fxWithEnvs('ISEMPTY(\$row\$)', listEnvs);
      expect(result, true);

      var mapEnvs = {
        "object": {
          "name": "Jeniffer",
        },
        "none": {},
      };
      result = fxWithEnvs('ISEMPTY(\$object\$)', mapEnvs);
      expect(result, false);
      result = fxWithEnvs('ISEMPTY(\$none\$)', mapEnvs);
      expect(result, true);
    });

    test('Test SUBSTRING', () {
      var result = fx('SUBSTRING("hello world", 3)');
      expect(result, "lo world");

      result = fx('SUBSTRING("hello world", 3, 4)');
      expect(result, "lo w");
    });

    test('Test REPLACESTRING', () {
      var result = fx('REPLACESTRING("hello world", "world", "newcore")');
      expect(result, "hello newcore");
    });

    test('Test REGMATCH', () {
      var reg = r"1[0-9]\d{9}$";
      var result = fx('REGMATCH("18721788876", r"$reg")');
      expect(result, true);

      result = fx('REGMATCH("zhan.yanyang@xinheyun.com", r"$reg")');
      expect(result, false);
    });
  });

  group('Test composite function', () {
    test('Test MAX and SUM and INTFLOOR and FIXED', () {
      var envs = {
        "column": [1, 2, 0.3, 4.5, 6]
      };
      var result = fxWithEnvs(
          '"hello" + FIXED(MAX(SUM(\$column\$), 1.2, 8 + 2, INTFLOOR(10.9)), 2)',
          envs);
      expect(result, "hello13.8");
    });
  });

  group('Test function apply', () {
    setUp(() {
      fxSetFunctionApply((name, arguments) {
        if (name == 'RMB') {
          return '¥${arguments.first}';
        }
      });
    });

    test('Test RMB', () {
      var result = fx('RMB(100)');
      expect(result, "¥100");
    });
  });
}
