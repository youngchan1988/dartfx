## 1.0.3

- 支持函数自定义处理

## 1.0.2

- 新增内置函数
  - 求绝对值： `num ABS(num a)`
  - 求平均值：`double AVERAGE(List<num> list)`
  - 求数字转换字符串：`String FIXED(num a, int digit)`
  - 求向上取整：`int INTCEIL(num a)`
  - 求向下取整：`int INTFLOOR(num a)`
  - 求是否空数据：`bool ISEMPTY(dynamic a)`, `a` is one of `String, List, Map`
  - 求最大值：`num MAX(num a, num b, [num c, ...])`
  - 求最小值：`num MIN(num a, num b, [num c, ...])`
  - 求正则判断结果：`bool REGMATCH(String source, r{String reg})`, reg参数前要加字符 `r` , 否则正则表达式中的特殊字符会被过滤掉
  - 替换字符串：`String SUBSTRING(String soruce, String old, String new)`
  - 求加和：`num SUM(List<num> list)`
  - 格式化时间戳：`String TIMEFORMAT(int timestamp, String pattern)`
  - 转换时间戳：`int TIMESTAMP(String dateString, String pattern)`
  - 字符串转数字：`num VALUE(String a)`

## 1.0.1

- 支持双 `$` 变量
- 新增 `fx(string)` 和 `fxWithEnvs(string, map)` 方法
- 补充Unit Test Case
- 完善js 库： `jsfx`
- 补充 js Unit Test Case

## 1.0.0

- 初始项目
