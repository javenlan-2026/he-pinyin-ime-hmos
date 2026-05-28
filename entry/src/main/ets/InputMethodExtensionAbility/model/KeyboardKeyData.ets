/**
 * 键盘按键数据 - KeyboardKeyData
 * 定义小鹤双拼输入法的按键布局
 */

// =============== 按键类型 ===============

export enum MenuType {
  NORMAL = 0,   // 字母键盘
  NUMBER = 1,   // 数字键盘
  SYMBOL = 2    // 符号键盘
}

export enum SubMenuType {
  NORMAL = 0,
  MENU = 1,
  EDIT = 2
}

export enum KeyState {
  LOWER_CASE = 0,      // 小写
  ONCE_UPPER_CASE = 1, // 首字母大写
  UPPER_CASE = 2       // 全大写
}

// =============== 按键数据接口 ===============

export interface KeySource {
  title: string;       // 按键标签（符号键显示）
  content: string;     // 小写内容
  upperContent: string; // 大写内容
}

// =============== 小鹤双拼键盘布局 ===============

// 字母行
export const LETTER_KEYS: KeySource[] = [
  { title: '1', content: 'q', upperContent: 'Q' },
  { title: '2', content: 'w', upperContent: 'W' },
  { title: '3', content: 'e', upperContent: 'E' },
  { title: '4', content: 'r', upperContent: 'R' },
  { title: '5', content: 't', upperContent: 'T' },
  { title: '6', content: 'y', upperContent: 'Y' },
  { title: '7', content: 'u', upperContent: 'U' },
  { title: '8', content: 'i', upperContent: 'I' },
  { title: '9', content: 'o', upperContent: 'O' },
  { title: '0', content: 'p', upperContent: 'P' }
];

// 第二行
export const SECOND_ROW_KEYS: KeySource[] = [
  { title: '~', content: 'a', upperContent: 'A' },
  { title: '!', content: 's', upperContent: 'S' },
  { title: '@', content: 'd', upperContent: 'D' },
  { title: '#', content: 'f', upperContent: 'F' },
  { title: '%', content: 'g', upperContent: 'G' },
  { title: "'", content: 'h', upperContent: 'H' },
  { title: '&', content: 'j', upperContent: 'J' },
  { title: '*', content: 'k', upperContent: 'K' },
  { title: '?', content: 'l', upperContent: 'L' }
];

// 第三行
export const THIRD_ROW_KEYS: KeySource[] = [
  { title: '-', content: 'z', upperContent: 'Z' },
  { title: '/', content: 'x', upperContent: 'X' },
  { title: ':', content: 'c', upperContent: 'C' },
  { title: '_', content: 'v', upperContent: 'V' },
  { title: ';', content: 'b', upperContent: 'B' },
  { title: '(', content: 'n', upperContent: 'N' },
  { title: ')', content: 'm', upperContent: 'M' }
];

// 数字行
export const NUMBER_KEYS: KeySource[] = [
  { title: '1', content: '1', upperContent: '1' },
  { title: '2', content: '2', upperContent: '2' },
  { title: '3', content: '3', upperContent: '3' },
  { title: '4', content: '4', upperContent: '4' },
  { title: '5', content: '5', upperContent: '5' },
  { title: '6', content: '6', upperContent: '6' },
  { title: '7', content: '7', upperContent: '7' },
  { title: '8', content: '8', upperContent: '8' },
  { title: '9', content: '9', upperContent: '9' },
  { title: '0', content: '0', upperContent: '0' }
];

// 符号行
export const SYMBOL_KEYS: KeySource[] = [
  { title: '`', content: '`', upperContent: '~' },
  { title: '-', content: '-', upperContent: '_' },
  { title: '=', content: '=', upperContent: '+' },
  { title: '[', content: '[', upperContent: '{' },
  { title: ']', content: ']', upperContent: '}' },
  { title: '\\', content: '\\', upperContent: '|' },
  { title: ';', content: ';', upperContent: ':' },
  { title: "'", content: "'", upperContent: '"' },
  { title: ',', content: ',', upperContent: '<' },
  { title: '.', content: '.', upperContent: '>' },
  { title: '/', content: '/', upperContent: '?' }
];

// =============== 功能键定义 ===============

export enum FunctionKeyType {
  SHIFT = 'shift',
  BACKSPACE = 'backspace',
  SPACE = 'space',
  ENTER = 'enter',
  SWITCH_MODE = 'switch_mode',
  NEXT_PAGE = 'next_page',
  PREV_PAGE = 'prev_page'
}

export interface FunctionKey {
  type: FunctionKeyType;
  icon: string;       // 图标或文字
  width: number;       // 宽度倍数
}

// 功能键列表
export const FUNCTION_KEYS: FunctionKey[] = [
  { type: FunctionKeyType.SHIFT, icon: '⇧', width: 1 },
  { type: FunctionKeyType.BACKSPACE, icon: '⌫', width: 1 },
  { type: FunctionKeyType.SWITCH_MODE, icon: '双拼', width: 1 },
  { type: FunctionKeyType.SPACE, icon: '', width: 2 },
  { type: FunctionKeyType.NEXT_PAGE, icon: '▶', width: 1 },
  { type: FunctionKeyType.ENTER, icon: '换行', width: 1 }
];

// =============== 按键配置 ===============

export const KEYBOARD_CONFIG = {
  ROW_HEIGHT: 48,      // 行高 (vp)
  KEY_MARGIN: 4,        // 按键间距 (vp)
  KEY_RADIUS: 8,        // 按键圆角 (vp)
  KEY_HEIGHT: 44,      // 按键高度 (vp)
  FUNCTION_KEY_HEIGHT: 40 // 功能键高度 (vp)
};

export default {
  LETTER_KEYS,
  SECOND_ROW_KEYS,
  THIRD_ROW_KEYS,
  NUMBER_KEYS,
  SYMBOL_KEYS,
  FUNCTION_KEYS,
  KEYBOARD_CONFIG,
  MenuType,
  SubMenuType,
  KeyState,
  FunctionKeyType
};