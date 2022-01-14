## 1.0.3

- Support custom resolver.

## 1.0.2

- Add some internal function
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

## 1.0.1

- Support double  `$`  variable. eg: `$user.name$`
- add `fx(string)` 和 `fxWithEnvs(string, map)` method
- Unit Test Case
- Build javascript library： `jsfx`
- JS Unit Test Case
