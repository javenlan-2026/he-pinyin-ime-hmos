/**
 * 键盘主页面 - Index
 * 小鹤双拼输入法软键盘UI实现
 */

import { deviceInfo } from '@kit.BasicServicesKit';
import { inputMethodEngine } from '@kit.IMEKit';
import {
  LETTER_KEYS, SECOND_ROW_KEYS, THIRD_ROW_KEYS,
  MenuType, SubMenuType, KeyState, FunctionKeyType,
  KEYBOARD_CONFIG, FunctionKey, KeySource
} from '../model/KeyboardKeyData';
import { InputHandler } from '../model/InputHandler';
import { ShuangpinEngine, CandidateManager } from '../../model/ShuangpinEngine';
import { SwipeInputEngine, KeyPosition } from '../../model/SwipeInputEngine';

const DEVICE_TYPE: string = deviceInfo.deviceType;
const TAG: string = 'Index';

@Entry
@Component
struct Index {
  // 菜单状态
  @State menuType: number = MenuType.NORMAL;
  @State subMenuType: number = SubMenuType.NORMAL;

  // 输入状态
  @State inputText: string = '';       // 当前输入
  @State candidates: string[] = [];    // 候选词列表
  @State currentPinyin: string = '';   // 当前拼音
  @State isShiftActive: boolean = false;
  @State isSwiping: boolean = false;  // 滑行状态
  @State swipePath: KeyPosition[] = []; // 滑行轨迹

  // 引擎实例
  private engine: ShuangpinEngine = new ShuangpinEngine();
  private candidateManager: CandidateManager = new CandidateManager();
  private swipeEngine: SwipeInputEngine = new SwipeInputEngine();
  private inputHandler: InputHandler = InputHandler.getInstance();

  // 按键位置映射（用于滑行输入）
  private keyPositions: KeyPosition[] = [];

  aboutToAppear(): void {
    // 监听编辑器属性变化
    try {
      inputMethodEngine.getKeyboardDelegate().on('editorAttributeChanged',
        (attr: inputMethodEngine.EditorAttribute) => {
          console.info(`recv editorAttributeChanged, immersiveMode: ${attr.immersiveMode}`);
        }
      );
    } catch (e) {
      console.error(`editorAttributeChanged error: ${e}`);
    }
  }

  /**
   * 处理按键按下
   */
  onKeyPress(key: string): void {
    console.info(`onKeyPress: ${key}`);

    if (key.length === 1 && /[a-zA-Z]/.test(key)) {
      // 字母键：处理双拼编码
      this.processShuangpin(key.toLowerCase());
    } else if (/[0-9]/.test(key)) {
      // 数字键：直接上屏或选字
      this.selectCandidate(parseInt(key) - 1);
    }
  }

  /**
   * 处理小鹤双拼输入
   */
  processShuangpin(key: string): void {
    const result = this.engine.processKey(key);

    this.currentPinyin = this.engine.getCurrentPinyin();

    if (result.isComplete) {
      // 拼音完成，查询候选词
      this.candidates = this.candidateManager.query(result.pinyin);
      console.info(`Candidates for ${result.pinyin}: ${this.candidates.join(', ')}`);
    }
  }

  /**
   * 选择候选词
   */
  selectCandidate(index: number): void {
    if (index >= 0 && index < this.candidates.length) {
      const selected = this.candidates[index];
      this.inputHandler.insertText(selected);
      this.engine.reset();
      this.currentPinyin = '';
      this.candidates = [];
      console.info(`Selected: ${selected}`);
    } else if (index === -1 && this.inputText.length > 0) {
      // 数字0选择第一个
      this.selectCandidate(0);
    }
  }

  /**
   * 处理功能键
   */
  onFunctionKey(type: FunctionKeyType): void {
    console.info(`onFunctionKey: ${type}`);

    switch (type) {
      case FunctionKeyType.SHIFT:
        this.isShiftActive = !this.isShiftActive;
        break;
      case FunctionKeyType.BACKSPACE:
        if (this.currentPinyin.length > 0) {
          this.engine.backspace();
          this.currentPinyin = this.engine.getCurrentPinyin();
          if (this.currentPinyin.length === 0) {
            this.candidates = [];
          }
        } else {
          this.inputHandler.deleteBackward(1);
        }
        break;
      case FunctionKeyType.SPACE:
        if (this.currentPinyin.length > 0 && this.candidates.length > 0) {
          this.selectCandidate(0);
        } else {
          this.inputHandler.insertText(' ');
        }
        break;
      case FunctionKeyType.ENTER:
        this.inputHandler.insertText('\n');
        break;
      case FunctionKeyType.SWITCH_MODE:
        // 切换双拼/全拼模式（预留）
        console.info('Switch mode');
        break;
      case FunctionKeyType.NEXT_PAGE:
        // 下一批候选
        break;
      case FunctionKeyType.PREV_PAGE:
        // 上一批候选
        break;
    }
  }

  /**
   * 滑行开始
   */
  onSwipeStart(x: number, y: number): void {
    this.isSwiping = true;
    this.swipePath = [];
    this.swipeEngine.startSwipe(x, y);
  }

  /**
   * 滑行中
   */
  onSwipeMove(x: number, y: number): void {
    if (this.isSwiping) {
      this.swipeEngine.addSwipePoint(x, y);
      this.swipePath = this.swipeEngine.getCurrentKeys() as unknown as KeyPosition[];
    }
  }

  /**
   * 滑行结束
   */
  onSwipeEnd(): void {
    if (this.isSwiping) {
      const path = this.swipeEngine.endSwipe();
      if (path && path.keys.length > 0) {
        // 遍历滑行路径中的每个键
        for (const key of path.keys) {
          this.processShuangpin(key);
        }
      }
      this.isSwiping = false;
      this.swipePath = [];
    }
  }

  /**
   * 取消滑行
   */
  onSwipeCancel(): void {
    this.swipeEngine.cancelSwipe();
    this.isSwiping = false;
    this.swipePath = [];
  }

  build() {
    Column() {
      // 候选词栏
      this.buildCandidateBar()

      // 键盘主体
      this.buildKeyboard()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  /**
   * 构建候选词栏
   */
  @Builder
  buildCandidateBar() {
    Row() {
      if (this.currentPinyin.length > 0) {
        // 显示当前拼音
        Text(this.currentPinyin)
          .fontSize(18)
          .fontColor('#333333')
          .margin({ left: 12 })
      }

      // 候选词列表
      if (this.candidates.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.candidates, (candidate: string, index: number) => {
              Text(`${index + 1} ${candidate}`)
                .fontSize(16)
                .fontColor('#333333')
                .padding(8)
                .backgroundColor(Color.White)
                .borderRadius(4)
                .onClick(() => {
                  this.selectCandidate(index);
                })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .height(44)
    .width('100%')
    .backgroundColor('#E8E8E8')
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建键盘
   */
  @Builder
  buildKeyboard() {
    Column({ space: 4 }) {
      // 第一行：数字和功能键
      this.buildNumberRow()

      // 第二行
      this.buildRow(SECOND_ROW_KEYS)

      // 第三行
      this.buildRow(THIRD_ROW_KEYS)

      // 第四行：功能键
      this.buildFunctionRow()
    }
    .width('100%')
    .padding(4)
    .layoutWeight(1)
  }

  /**
   * 构建数字行
   */
  @Builder
  buildNumberRow() {
    Row({ space: 4 }) {
      // 切换模式按钮
      Button('双拼')
        .fontSize(12)
        .height(36)
        .width(48)
        .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .borderRadius(4)
        .onClick(() => {
          this.onFunctionKey(FunctionKeyType.SWITCH_MODE);
        })

      // 数字键
      ForEach(LETTER_KEYS, (key: KeySource) => {
        this.buildKey(key)
      })

      // 删除键
      Button('⌫')
        .fontSize(16)
        .height(36)
        .width(48)
        .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .borderRadius(4)
        .onClick(() => {
          this.onFunctionKey(FunctionKeyType.BACKSPACE);
        })
    }
    .width('100%')
    .padding({ left: 4, right: 4 })
  }

  /**
   * 构建字母行
   */
  @Builder
  buildRow(keys: KeySource[]) {
    Row({ space: 4 }) {
      ForEach(keys, (key: KeySource) => {
        this.buildKey(key)
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  /**
   * 构建单个按键
   */
  @Builder
  buildKey(key: KeySource) {
    Button(key.content)
      .fontSize(18)
      .height(KEYBOARD_CONFIG.KEY_HEIGHT)
      .layoutWeight(1)
      .backgroundColor(Color.White)
      .fontColor('#333333')
      .borderRadius(KEYBOARD_CONFIG.KEY_RADIUS)
      .onClick(() => {
        this.onKeyPress(key.content);
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          // 记录按键位置用于滑行
        } else if (event.type === TouchType.Up) {
          this.onSwipeEnd();
        } else if (event.type === TouchType.Move) {
          // 滑行过程中
        }
      })
  }

  /**
   * 构建功能行
   */
  @Builder
  buildFunctionRow() {
    Row({ space: 4 }) {
      // 切换键
      Button(this.isShiftActive ? '⇧' : '⇪')
        .fontSize(14)
        .height(36)
        .width(48)
        .backgroundColor(this.isShiftActive ? '#007AFF' : '#E0E0E0')
        .fontColor(this.isShiftActive ? Color.White : '#333333')
        .borderRadius(4)
        .onClick(() => {
          this.onFunctionKey(FunctionKeyType.SHIFT);
        })

      // 符号键
      Button(',')
        .fontSize(16)
        .height(36)
        .width(36)
        .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .borderRadius(4)
        .onClick(() => {
          this.onKeyPress(',');
        })

      // 空格键
      Button('')
        .fontSize(14)
        .height(36)
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .fontColor('#666666')
        .borderRadius(4)
        .onClick(() => {
          this.onFunctionKey(FunctionKeyType.SPACE);
        })

      // 句号键
      Button('.')
        .fontSize(16)
        .height(36)
        .width(36)
        .backgroundColor('#E0E0E0')
        .fontColor('#333333')
        .borderRadius(4)
        .onClick(() => {
          this.onKeyPress('.');
        })

      // 回车键
      Button('换行')
        .fontSize(14)
        .height(36)
        .width(60)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .borderRadius(4)
        .onClick(() => {
          this.onFunctionKey(FunctionKeyType.ENTER);
        })
    }
    .width('100%')
    .padding({ left: 4, right: 4 })
  }
}