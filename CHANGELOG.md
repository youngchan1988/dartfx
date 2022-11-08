## 1.0.13

* export error token
* close quote support '$'

## 1.0.10

- fix: resolve CONTAIN null parameters

## 1.0.9

- Fix empty expression.

## 1.0.8

- Change `fx(String)` to `fx(String, {GetEnvValue?})`.

## 1.0.7

- Fix parse `JsObject.undefined` value.
- Fix runtime `executeBinaryExpression.left` & `executeBinaryExpression.right` null value.

## 1.0.5

Add some internal functions

- `num POW(num x, num exponent)`
- `num SQRT(num x)`
- `bool CONTAIN(List list,  List sub)`

## 1.0.4

- Update License.
- Rename `fxSetFunctionApply` to `fxSetFunctionResolver`.

## 1.0.3

- Support custom resolver.
- Add `fxSetFunctionApply((List args){})` method.

## 1.0.2

- Add some internal functions
  - `num ABS(num a)`
  - `double AVERAGE(List<num> list)`
  - `String FIXED(num a, int digit)`
  - `int INTCEIL(num a)`
  - `int INTFLOOR(num a)`
  - `bool ISEMPTY(dynamic a)`, `a` is one of `String, List, Map`
  - `num MAX(num a, num b, [num c, ...])`
  - `num MIN(num a, num b, [num c, ...])`
  - `bool REGMATCH(String source, r{String reg})`. The `reg` argument need prefix char `r`. Like `r"1[0-9]\d{9}$"`
  - `String SUBSTRING(String s, int start, [int length])`
  - `String REPLACESTRING(String soruce, String old, String new)`
  - `num SUM(List<num> list)`
  - `String TIMEFORMAT(int timestamp, String pattern)`
  - `int TIMESTAMP(String dateString, String pattern)`
  - `num VALUE(String a)`
- Add `fxAssignment(string, map)` method.

## 1.0.1

- Support double  `$`  variable. eg: `$user.name$`.
- Add `fx(string)` 和 `fxWithEnvs(string, map)` method.
- Unit Test Case.
- Build javascript library： `jsfx`.
- JS Unit Test Case.
