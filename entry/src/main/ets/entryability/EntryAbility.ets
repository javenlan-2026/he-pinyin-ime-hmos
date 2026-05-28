/**
 * 应用入口 Ability - EntryAbility
 * 鸿蒙应用主入口，负责应用生命周期管理
 */

import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const TAG: string = 'EntryAbility';
const DOMAIN: number = 0xFF00;

export default class EntryAbility extends Uiability {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onWindowStageCreate');

    // 加载主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content: ' + JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onWindowStageDestroy');
  }

  onContinue(wantParam: string): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onContinue');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onNewWant');
  }

  onDump(): string[] {
    hilog.info(DOMAIN, TAG, 'EntryAbility onDump');
    return [];
  }
}
