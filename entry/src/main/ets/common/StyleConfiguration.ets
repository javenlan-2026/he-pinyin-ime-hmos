/**
 * 样式配置 - StyleConfiguration
 * 定义键盘样式和响应式布局参数
 */

export interface KeyStyle {
  keyWidth: number;
  keyHeight: number;
  keyMargin: number;
  keyRadius: number;
  fontSize: number;
}

const PHONE_KEY_STYLE: KeyStyle = {
  keyWidth: 32,
  keyHeight: 44,
  keyMargin: 4,
  keyRadius: 8,
  fontSize: 18
};

const TABLET_KEY_STYLE: KeyStyle = {
  keyWidth: 48,
  keyHeight: 56,
  keyMargin: 6,
  keyRadius: 10,
  fontSize: 22
};

class StyleConfiguration {
  /**
   * 获取键盘样式
   * @param isLandscape 是否横屏
   * @param isRkDevice 是否为Rk设备
   * @param deviceType 设备类型
   */
  static getInputStyle(isLandscape: boolean, isRkDevice: boolean, deviceType: string): KeyStyle {
    // 平板使用更大尺寸
    if (deviceType === 'tablet') {
      return TABLET_KEY_STYLE;
    }

    // 手机使用默认尺寸
    return PHONE_KEY_STYLE;
  }

  /**
   * 获取响应式布局参数
   */
  static getLayoutParams(screenWidth: number, screenHeight: number): { keyHeight: number; keyboardHeight: number } {
    const isLandscape = screenWidth > screenHeight;
    const keyboardHeightRatio = isLandscape ? 0.25 : 0.35;

    return {
      keyHeight: isLandscape ? 40 : 44,
      keyboardHeight: screenHeight * keyboardHeightRatio
    };
  }
}

export default StyleConfiguration;