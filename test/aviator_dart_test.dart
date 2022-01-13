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
}
