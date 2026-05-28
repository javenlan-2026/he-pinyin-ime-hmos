/**
 * 键盘控制器 - KeyboardController
 * 管理输入法窗口、键盘事件和文本输入
 */

import { inputMethodEngine } from '@kit.IMEKit';
import { display } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { InputHandler } from './InputHandler';
import StyleConfiguration from '../../common/StyleConfiguration';

// 设备尺寸常量
const DEVICE_PHONE_WIDTH = 720;
const DEVICE_PHONE_HEIGHT = 1280;
const KEYBOARD_HEIGHT_RATE = 0.35;  // 键盘高度占屏幕比例

export class KeyboardController {
  private context: inputMethodEngine.InputMethodExtensionContext | undefined = undefined;
  private panel: inputMethodEngine.Panel | undefined = undefined;
  private inputHandler: InputHandler = InputHandler.getInstance();
  private keyboardDelegate: inputMethodEngine.KeyboardDelegate | undefined = undefined;
  private barPosition: number = 0;
  private isKeyboardShow: boolean = false;

  /**
   * 初始化输入法
   */
  onCreate(context: inputMethodEngine.InputMethodExtensionContext): void {
    this.context = context;
    console.info('KeyboardController onCreate');
    this.initWindow();
    this.registerListener();
  }

  /**
   * 销毁输入法
   */
  onDestroy(): void {
    console.info('KeyboardController onDestroy');
    this.unRegisterListener();
    this.destroyPanel();
  }

  /**
   * 初始化窗口
   */
  private initWindow(): void {
    if (this.context === undefined) {
      return;
    }

    console.info('initWindow');
    let dis: display.Display | undefined = undefined;

    try {
      dis = display.getDefaultDisplaySync();
    } catch (err) {
      const error = err as BusinessError;
      console.error(`getDefaultDisplaySync error: ${error.code} ${error.message}`);
      return;
    }

    if (dis === undefined) {
      return;
    }

    const dWidth = dis.width;
    const dHeight = dis.height;
    const keyHeight = dHeight * KEYBOARD_HEIGHT_RATE;

    this.barPosition = dHeight - keyHeight;

    console.info(`initWindow - width: ${dWidth}, height: ${dHeight}, keyboard height: ${keyHeight}`);

    const panelInfo: inputMethodEngine.PanelInfo = {
      type: inputMethodEngine.PanelType.SOFT_KEYBOARD,
      flag: inputMethodEngine.PanelFlag.FLG_FIXED
    };

    const inputStyle = StyleConfiguration.getInputStyle(false, false, 'phone');

    inputmethodAbility.createPanel(this.context, panelInfo).then((panel: inputMethodEngine.Panel) => {
      this.panel = panel;
      panel.resize(dWidth, keyHeight).then(() => {
        panel.setUiContent('InputMethodExtensionAbility/pages/Index').then(() => {
          console.info('loadContent finished');
        }).catch((err: BusinessError) => {
          console.error(`Failed to setUiContent: ${err.code} ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(`Failed to resize: ${err.code} ${err.message}`);
      });
    }).catch((err: BusinessError) => {
      console.error(`Failed to createPanel: ${err.code} ${err.message}`);
    });
  }

  /**
   * 注册事件监听
   */
  private registerListener(): void {
    console.info('registerListener');

    // 屏幕变化监听
    try {
      display.on('change', () => {
        this.resizePanel();
      });
    } catch (err) {
      console.error(`display on change error: ${(err as BusinessError).message}`);
    }

    // 输入开始
    inputmethodAbility.on('inputStart',
      (kbController: inputMethodEngine.KeyboardController, textInputClient: inputMethodEngine.InputClient) => {
        console.info('keyboard inputStart');
        this.inputHandler.onInputStart(kbController, textInputClient);
      });

    // 输入停止
    inputmethodAbility.on('inputStop', () => {
      console.info('keyboard inputStop');
      this.onDestroy();
    });

    // 键盘代理
    this.keyboardDelegate = inputMethodEngine.getKeyboardDelegate();

    // 按键按下
    this.keyboardDelegate.on('keyDown', (keyEvent: inputMethodEngine.KeyEvent) => {
      console.info(`keyDown: code = ${keyEvent.keyCode}`);
      return true;
    });

    // 按键抬起
    this.keyboardDelegate.on('keyUp', (keyEvent: inputMethodEngine.KeyEvent) => {
      console.info(`keyUp: code = ${keyEvent.keyCode}`);
      return true;
    });

    // 光标上下文变化
    this.keyboardDelegate.on('cursorContextChange', (x: number, y: number, height: number) => {
      console.info(`cursorContextChange: x=${x}, y=${y}, height=${height}`);
    });
  }

  /**
   * 取消事件监听
   */
  private unRegisterListener(): void {
    console.info('unRegisterListener');
    inputmethodAbility.off('inputStop');
    inputmethodAbility.off('inputStart');

    if (this.keyboardDelegate) {
      this.keyboardDelegate.off('keyDown');
      this.keyboardDelegate.off('keyUp');
      this.keyboardDelegate.off('cursorContextChange');
    }
  }

  /**
   * 销毁面板
   */
  private destroyPanel(): void {
    console.info('destroyPanel');
    if (this.panel) {
      inputmethodAbility.destroyPanel(this.panel).then(() => {
        console.info('Succeeded in destroyPanel');
      }).catch((err: BusinessError) => {
        console.error(`Failed to destroyPanel: ${err.code} ${err.message}`);
      });
    }
  }

  /**
   * 调整面板大小
   */
  private resizePanel(): void {
    console.info('resizeWindow');
    let dis: display.Display | undefined = undefined;

    try {
      dis = display.getDefaultDisplaySync();
    } catch (err) {
      console.error(`getDefaultDisplaySync error: ${(err as BusinessError).message}`);
      return;
    }

    if (dis === undefined) {
      return;
    }

    const dWidth = dis.width;
    const dHeight = dis.height;
    const keyHeight = dHeight * KEYBOARD_HEIGHT_RATE;

    if (this.panel) {
      this.panel.resize(dWidth, keyHeight).then(() => {
        console.info('resizePanel succeeded');
      }).catch((err: BusinessError) => {
        console.error(`resizePanel error: ${err.code} ${err.message}`);
      });
    }
  }
}

// 导出单例
export const keyboardController: KeyboardController = new KeyboardController();