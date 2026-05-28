/**
 * 日志工具 - Log
 * 统一日志输出
 */

const DEBUG = true;

export class Log {
  static showInfo(tag: string, message: string): void {
    if (DEBUG) {
      console.info(`[${tag}] ${message}`);
    }
  }

  static showError(tag: string, message: string): void {
    console.error(`[${tag}] ERROR: ${message}`);
  }

  static showDebug(tag: string, message: string): void {
    if (DEBUG) {
      console.info(`[${tag}] DEBUG: ${message}`);
    }
  }
}

export default Log;