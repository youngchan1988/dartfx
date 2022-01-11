<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

## Features

公式计算，支持:

- 双 $ 变量处理
- 运算表达式
- TODO： 自定义函数

## Getting started

### Dart:

git: [Mobile / dartfx · GitLab (newcoretech.com)](https://g.newcoretech.com/mobile/dartfx)

### JS:

项目目录下执行： `make buildjs`

成功后会在 `js` 目录下生成 `fx.js` 文件

## Usage

### Dart：

```dart
import 'package:dartfx/dartfx.dart';


void expression(){
  var result = fx("1+(2+3)*7-4");
  print('Fx result: $result');
}

void expressionWithEnv(){
  var result = fxWithEnvs('\\$43859.currency\\$+\\$43859.unitName\\$+\"number\"', {
    "43858": {"unitName": "单位"},
    "43859": {"currency": "100", "unitName": "人民币"}
  });
  print('Fx output: $result');
}
```

### JS:

```typescript
import './fx';

declare var fx: Function;
declare var fxWithEnvs: Function;

console.log(fx("1+2*3-2"));

console.log(fxWithEnvs("\\$43859.currency\\$+\\$43859.unitName\\$+\"number\"", {
    "43858": {"unitName": "单位"},
    "43859": {"currency": "100", "unitName": "人民币"}
  }));
```
