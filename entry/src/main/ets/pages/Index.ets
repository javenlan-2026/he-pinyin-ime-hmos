/**
 * 应用主页面 - Index
 * 用于输入法主应用入口（引导用户设置输入法）
 */

import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = '小鹤双拼输入法';

  build() {
    Column() {
      // 标题
      Text('小鹤双拼')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 8 })

      Text('for HarmonyOS Next')
        .fontSize(16)
        .fontColor('#888888')
        .margin({ bottom: 60 })

      // Logo 占位
      Column() {
        Text('🦢')
          .fontSize(80)
      }
      .margin({ bottom: 40 })

      // 版本信息
      Column({ space: 8 }) {
        Text('v1.0.0')
          .fontSize(14)
          .fontColor('#999999')
        Text('小鹤双拼输入法 · HarmonyOS Next')
          .fontSize(12)
          .fontColor('#BBBBBB')
      }
      .margin({ bottom: 40 })

      // 设置步骤说明
      Column() {
        Text('启用输入法步骤')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 20 })

        Column({ space: 16 }) {
          this.buildStep('1', '打开「设置」')
          this.buildStep('2', '进入「系统与更新」')
          this.buildStep('3', '点击「语言与输入」')
          this.buildStep('4', '点击「默认键盘」')
          this.buildStep('5', '开启「小鹤双拼」并设为默认')
        }
        .padding(16)
      }
      .padding(24)
      .backgroundColor('#F5F5F5')
      .borderRadius(16)
      .margin({ left: 24, right: 24 })

      // 提示
      Text('首次使用需设置为默认键盘')
        .fontSize(14)
        .fontColor('#007AFF')
        .margin({ top: 20 })

      Blank()

      // 底部信息
      Column() {
        Text('声明：本应用仅供学习研究使用')
          .fontSize(12)
          .fontColor('#CCCCCC')
        Text('小鹤双拼方案版权归原作者所有')
          .fontSize(12)
          .fontColor('#CCCCCC')
          .margin({ top: 4 })
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor(Color.White)
  }

  @Builder
  buildStep(number: string, title: string) {
    Row({ space: 12 }) {
      Text(number)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width(24)
        .height(24)
        .backgroundColor('#007AFF')
        .borderRadius(12)

      Text(title)
        .fontSize(16)
        .fontColor('#333333')
    }
    .width('100%')
  }
}