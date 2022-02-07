![1642346505729.png](https://tva1.sinaimg.cn/large/008i3skNgy1gz56h0qv3lj30qs0atq35.jpg)

> This project was developed on [dart-analyzer](https://github.com/dart-lang/sdk/tree/main/pkg/analyzer)

## Features

Support dart and javascript both.

### Operators

```dart
+, -, *, /, ~/, %, -(Negative), >, <, ==, >=, <=, !=, &&, ||, !, &, |,
~, ^, >>, <<, =, +=, -=, &=, |=, ^=, >>=, <<=, expr1 ? expr2 : expr3
```

The operator doc : [Operators | Dart](https://dart.dev/guides/language/language-tour#operators)

### Internal Functions

| Function                                                        | Comment                                                                                                                          |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `num ABS(num a)`                                              | Return absolutely value of number.                                                                                               |
| `num SUM(List list)`                                          | Return sum value of a number set.                                                                                                |
| `double AVERAGE(List list)`                                   | Return average value of a number set.                                                                                            |
| `num ROUND(num value, int digit)`                             | Return number value closest to this and limit digits after the decimal point.                                                    |
| `String FIXED(num value, int digit)`                          | Return string value closest to this and limit digits after the decimal point.                                                    |
| `int INTCEIL(num value)`                                      | Return the least integer value no smaller than this.                                                                             |
| `int INTFLOOR(num value)`                                     | Return the greatest integer value no greater than this.                                                                          |
| `num POW(num x, num exp)`                                     | Returns `x` to the power of `exp`.                                                                                           |
| `num SQRT(num x)`                                             | Converts `x` to a double and returns the positive square root of the value.                                                    |
| `bool CONTAIN(List list, List sub)`                           | Return `list` is contains all elements in `sub`.                                                                             |
| `bool ISEMPTY(dynamic value)`                                 | Return value is empty or not. The value should be one of String, List or Map.                                                    |
| `num MAX(num a, num b, [num c, ...])`                         | Return the max value of number arguments.                                                                                        |
| `num MIN(num a, num b, [num c, ...])`                         | Return the min value of number arguments.                                                                                        |
| `num VALUE(String a)`                                         | Convert string to number.                                                                                                        |
| `bool REGMATCH(String source, r{String reg})`                 | Return the string is match regular rule, true of false. The `reg` argument need a prefix char `r`. eg: `r"1[0-9]\d{9}$"` . |
| `String SUBSTRING(String s, int start, [int length])`         | Return sub string.                                                                                                               |
| `String REPLACESTRING(String soruce, String old, String new)` | Replace sub string by a new one. And return the new string.                                                                      |
| `String TIMEFORMAT(int timestamp, String pattern)`            | Return the formated timestamp. The `pattern` could be "yyyy-MM-dd HH:mm:ss".                                                   |
| `int TIMESTAMP(String dateString, String pattern)`            | Return the timestamp value that parse from a string.                                                                             |

## Getting started

```yaml
dependencies:
    dartfx: ^1.0.5
```

To build `jsfx`.

`make buildjs`

## Usage

### Dart：

```dart
import 'package:dartfx/dartfx.dart';

void main(){
  var result = fx("1+(2+3)*7-4");
  print('Fx output: $result');

  var envs = {
    "43858": {"message": "hello"},
    "43859": {"currency": "100", "unitName": "Yuan"}
  };

  result = fxWithEnvs('\$43859.currency\$+\$43859.unitName\$', envs);
  print('Fx output: $result');

  result = fxAssignment('\$43858.message\$=\$43859.currency\$+\$43859.unitName\$', envs);
  print('Fx output: ${envs["43858"]["message"]}');

  fxSetFunctionApply((name, arguments) {
    if (name == 'RMB') {
      return '¥${arguments.first}';
    }
  });
  result = fx('RMB(100)');
  print('Fx output: $result');
}
```

### JS:

```typescript
import { fx, fxWithEnvs, fxAssignment, fxSetFunctionApply } from './jsfx';

console.log(fx('1+(2+3)*7 - 4/2'));

var envs = {
    "43858": { "message": "hello" },
    "43859": { "currency": "100", "unitName": "Yuan" }
};
console.log(fxWithEnvs('\$43859.currency\$+\$43859.unitName\$', envs));

var result = fxAssignment('\$43858.message\$=\$43859.currency\$+\$43859.unitName\$', envs);
console.log(envs["43858"]["message"]);

fxSetFunctionApply((...args) => {
    var funcName = args[0];
    if (funcName == 'RMB') {
        var value = args[1];
        return `¥${value}`;
    }
});
console.log(fx('RMB(100)'));
```

# License

See [LICENSE](LICENSE)
