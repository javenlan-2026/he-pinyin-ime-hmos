/**
 * 输入处理器 - InputHandler
 * 处理文本插入、删除、光标移动等操作
 */

import { inputMethodEngine } from '@kit.IMEKit';

export class InputHandler {
  private static instance: InputHandler;
  private kbController: inputMethodEngine.KeyboardController | undefined;
  private textClient: inputMethodEngine.InputClient | undefined;

  private constructor() {}

  /**
   * 获取单例
   */
  static getInstance(): InputHandler {
    if (!InputHandler.instance) {
      InputHandler.instance = new InputHandler();
    }
    return InputHandler.instance;
  }

  /**
   * 输入开始回调
   */
  onInputStart(kbController: inputMethodEngine.KeyboardController, textClient: inputMethodEngine.InputClient): void {
    this.kbController = kbController;
    this.textClient = textClient;
    console.info('InputHandler onInputStart');
  }

  /**
   * 插入文本
   */
  insertText(text: string): void {
    if (this.textClient) {
      this.textClient.insertText(text).then(() => {
        console.info(`insertText: ${text}`);
      }).catch((err: Error) => {
        console.error(`insertText error: ${err.message}`);
      });
    }
  }

  /**
   * 删除前向文本
   */
  deleteForward(length: number): void {
    if (this.textClient) {
      this.textClient.deleteForward(length).then(() => {
        console.info(`deleteForward: ${length}`);
      }).catch((err: Error) => {
        console.error(`deleteForward error: ${err.message}`);
      });
    }
  }

  /**
   * 删除后向文本
   */
  deleteBackward(length: number): void {
    if (this.textClient) {
      this.textClient.deleteBackward(length).then(() => {
        console.info(`deleteBackward: ${length}`);
      }).catch((err: Error) => {
        console.error(`deleteBackward error: ${err.message}`);
      });
    }
  }

  /**
   * 移动光标
   */
  moveCursor(direction: inputMethodEngine.Direction): void {
    if (this.textClient) {
      this.textClient.moveCursor(direction).then(() => {
        console.info(`moveCursor: ${direction}`);
      }).catch((err: Error) => {
        console.error(`moveCursor error: ${err.message}`);
      });
    }
  }

  /**
   * 隐藏键盘
   */
  hideKeyboardSelf(): void {
    if (this.kbController) {
      this.kbController.hideKeyboard().then(() => {
        console.info('hideKeyboard succeeded');
      }).catch((err: Error) => {
        console.error(`hideKeyboard error: ${err.message}`);
      });
    }
  }

  /**
   * 发送私有命令
   */
  sendPrivateCommand(command: Record<string, inputMethodEngine.CommandDataType>): void {
    if (this.textClient) {
      this.textClient.sendPrivateCommand(command).then(() => {
        console.info('sendPrivateCommand succeeded');
      }).catch((err: Error) => {
        console.error(`sendPrivateCommand error: ${err.message}`);
      });
    }
  }
}