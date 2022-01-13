/*
* Author: YoungChan
* Date: 2022-01-12 15:45:05
* LastEditors: YoungChan
* LastEditTime: 2022-01-13 09:46:51
* Description: description
* Copyright: ©2022 NEW CORE Technology Co. Ltd.
*/
import './fx.js';

//declare function;
declare var jsfx: Function;
declare var jsfxWithEnvs: Function;
declare var jsfxAssignment: Function;

// 运行公式表达式并返回结果
export function fx(expression: string): any {
	return jsfx(expression);
}

/* 
* 运行包含变量声明（$...$）的公式表达式，并返回结果
* expression: 公式表达式
* envs: 变量值对象{}
*/
export function fxWithEnvs(expression: string, envs: object): any {
	return jsfxWithEnvs(expression, envs);
}

/* 
* 运行包含变量声明（$...$）的赋值表达式，赋值的结果更新在`envs`中
* expression: 赋值公式表达式，如：$a.b$=1+2+3
* envs: 变量值对象{}
*/
export function fxAssignment(expression: string, envs: object): any {
	return jsfxAssignment(expression, envs);
}