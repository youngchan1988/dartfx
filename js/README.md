# Get Started

主要代码文件说明：

- fx.js: 核心代码库
- jsfx.ts: 对 `fx.js` 的封装，向上提供 `TypeScript` 接口
- jsfx.test.ts: 单元测试代码，有一些使用示例

# Usage

`jsfx` 提供了3个接口方法：

- `fx(expression: string): any`: 运行公式表达式
- `fxWithEnvs(expression: string, envs: object): any`: 运行含变量的公式表达式
- `fxAssignment(expression: string, envs: object): any`: 运行赋值公式表达式

```typescript
var result = fx('1+(2+3)*7 - 4/2');

var envs = {
		"43858": { "message": "单位" },
		"43859": { "currency": "100", "unitName": "人民币" }
	};
var result = fxWithEnvs('\$43859.currency\$+\$43859.unitName\$', envs);

var result = fxAssignment('\$43858.message\$=\$43859.currency\$+\$43859.unitName\$', envs);

```

# Unit Test

```bash
npm i

npm run test
```
