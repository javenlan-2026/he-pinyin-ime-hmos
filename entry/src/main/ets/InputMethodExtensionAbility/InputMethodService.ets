/**
 * 小鹤双拼输入法服务 - InputMethodService
 * 继承 InputMethodExtensionAbility 实现输入法核心逻辑
 */

import { InputMethodExtensionAbility } from '@kit.IMEKit';
import { Want } from '@kit.AbilityKit';
import { keyboardController } from './model/KeyboardController';
import Log from '../model/Log';

const TAG: string = 'InputMethodService';

export default class InputMethodService extends InputMethodExtensionAbility {
  onCreate(want: Want): void {
    console.info(TAG, `onCreate want: ${want.abilityName}`);
    keyboardController.onCreate(this.context);
  }

  onDestroy(): void {
    console.info(TAG, 'onDestroy');
    keyboardController.onDestroy();
  }
}