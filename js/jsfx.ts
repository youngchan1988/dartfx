// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import './fx.js';

//declare function;
declare var jsfx: Function;
declare var jsfxWithEnvs: Function;
declare var jsfxAssignment: Function;
declare var jsSetFunctionResolver: Function;

/*
* Run expression and return the result.
*
* onGetEnvValue: Enviroment value callback function.
*/
export function fx(expression: string, onGetEnvValue?: Function): any {
	return jsfx(expression, onGetEnvValue);
}

/* 
* Run expression and return the result.
*
* envValues: Enviroment values set. If the expression contains a variable `$a.b$`. Then
*       you should give a values set like `{"a": {"b": something}}`.
*/
export function fxWithEnvs(expression: string, envValues: object): any {
	return jsfxWithEnvs(expression, envValues);
}

/* 
* Run assignment expression and return the right side value.
*
* expression: Assignment expression，eg: `$a.b$=1+2+3`.
* envValues: Enviroment values set. If the expression contains a variable `$a.b$`. Then
*       you should give a values set like `{"a": {"b": something}}`.
* leftEnvs: Used for [jsfxAssignment] in `jsfx.dart`.
*/
export function fxAssignment(expression: string, envValues: object): any {
	return jsfxAssignment(expression, envValues);
}

/*
* If there is a function witch the internal functions doesn't have. You can custom
* your own function by set a [FunctionResolver].
*/
export function fxSetFunctionResolver(functionResolver: Function) {
	jsSetFunctionResolver(functionResolver);
}