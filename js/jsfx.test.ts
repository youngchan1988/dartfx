/*
* Author: YoungChan
* Date: 2022-01-10 19:31:26
* LastEditors: YoungChan
* LastEditTime: 2022-01-12 20:01:57
* Description: description
* Copyright: ©2022 NEW CORE Technology Co. Ltd.
*/
import './d8';
import { fx, fxWithEnvs, fxAssignment } from './jsfx';

test('Test arithmetic', () => {
	var result = fx('1+(2+3)*7 - 4/2');
	expect(result).toBe(34);
});

test('Test remainder', () => {
	var result = fx('9%4');
	expect(result).toBe(1);
});

test('Test divide to integer', () => {
	var result = fx('9~/4');
	expect(result).toBe(2);
});

test('Test negative', () => {
	var result = fx('-3+9');
	expect(result).toBe(6);
});

test('Test great', () => {
	var result = fx('3>0 && 3>=3');
	expect(result).toBe(true);
});

test('Test less', () => {
	var result = fx('3<0 && 3<=3');
	expect(result).toBe(false);
});

test('Test equal', () => {
	var result = fx('3==3');
	expect(result).toBe(true);
});

test('Test not equal', () => {
	var result = fx('3!=3');
	expect(result).toBe(false);
});

test('Test and or not', () => {
	var result = fx('(3>0 && 3>1) || !(0<-1)');
	expect(result).toBe(true);
});

test('Test and calc', () => {
	var result = fx('0x22 & 0x07');
	expect(result).toBe(0x02);
});

test('Test or calc', () => {
	var result = fx('0x22 | 0x05');
	expect(result).toBe(0x27);
});

test('Test not calc', () => {
	var result = fx('~0x22&0xFF');
	expect(result).toBe(0xDD);
});

test('Test not or calc', () => {
	var result = fx('0x22 ^ 0x07');
	expect(result).toBe(0x25);
});

test('Test left move', () => {
	var result = fx('0x22 << 2');
	expect(result).toBe(0x88);
});

test('Test right move', () => {
	var result = fx('0x22 >> 1');
	expect(result).toBe(0x11);
});

test('Test condition', () => {
	var result = fx('3>0 && 1<3 ? "yes": "no"');
	expect(result).toBe("yes");
});

test('Test env value', () => {
	var envs = {
		"43858": { "message": "单位" },
		"43859": { "currency": "100", "unitName": "人民币" }
	};
	var result = fxWithEnvs('\$43859.currency\$+\$43859.unitName\$', envs);
	expect(result).toBe("100人民币");
});

test('Test env assignment', () => {
	var envs = {
		"43858": { "message": "单位" },
		"43859": { "currency": "100", "unitName": "人民币" }
	};
	fxAssignment(
		'\$43858.message\$=\$43859.currency\$+\$43859.unitName\$', envs);
	expect(envs["43858"]!["message"]).toBe("100人民币");
});

test('Test +=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};

	fxAssignment('\$43858.number\$+=\$43859.currency\$', envs);
	expect(envs["43858"]!["number"]).toBe(200);
});

test('Test -=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$-=\$43859.currency\$', envs);
	expect(envs["43858"]!["number"]).toBe(0);
});

test('Test *=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$*=\$43859.currency\$', envs);
	expect(envs["43858"]!["number"]).toBe(10000);
});

test('Test %=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$%=8', envs);
	expect(envs["43858"]!["number"]).toBe(4);
});

test('Test &=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$&=0x07', envs);
	expect(envs["43858"]!["number"]).toBe(4);
});

test('Test |=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$|=0x07', envs);
	expect(envs["43858"]!["number"]).toBe(103);
});

test('Test ^=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$^=0x07', envs);
	expect(envs["43858"]!["number"]).toBe(99);
});

test('Test >>=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$>>=2', envs);
	expect(envs["43858"]!["number"]).toBe(25);
});

test('Test <<=', () => {
	var envs = {
		"43858": { "number": 100 },
		"43859": { "currency": 100, "unitName": "人民币" }
	};
	fxAssignment('\$43858.number\$<<=2', envs);
	expect(envs["43858"]!["number"]).toBe(400);
});