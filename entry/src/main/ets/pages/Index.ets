/**
 * 应用主页面 - Index
 * 用于输入法主应用入口（不是输入法键盘页面）
 */

@Entry
@Component
struct Index {
  @State message: string = '小鹤双拼输入法 for HarmonyOS Next'

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      Text('输入法已安装，请在系统设置中启用')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 12 })

      Text('设置路径：设置 > 系统 > 语言与输入法 > 键盘管理 > 小鹤双拼')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .padding(24)
  }
}
