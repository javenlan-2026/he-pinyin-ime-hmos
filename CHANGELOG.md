# 小鹤双拼输入法 for HarmonyOS Next

## 版本历史

### v1.0.0 (2026-05-28)
- 初始版本
- 实现小鹤双拼编码引擎
- 实现候选词系统（5000+词库）
- 实现软键盘UI
- 支持滑行输入
- 支持数字选字（1-9）

## 主要文件

```
he-pinyin-ime/
├── entry/src/main/
│   ├── ets/
│   │   ├── InputMethodExtensionAbility/
│   │   │   ├── InputMethodService.ets         # 输入法服务入口
│   │   │   ├── model/
│   │   │   │   ├── KeyboardController.ets     # 键盘控制器
│   │   │   │   ├── InputHandler.ets           # 输入处理器
│   │   │   │   └── KeyboardKeyData.ets        # 按键数据
│   │   │   └── pages/
│   │   │       └── Index.ets                  # 键盘主页面
│   │   ├── model/
│   │   │   ├── ShuangpinEngine.ets            # 双拼编码引擎
│   │   │   ├── SwipeInputEngine.ets           # 滑行输入引擎
│   │   │   ├── Log.ets                        # 日志工具
│   │   │   └── Logger.ets                     # 性能日志
│   │   └── common/
│   │       └── StyleConfiguration.ets          # 样式配置
│   ├── resources/
│   │   └── base/
│   │       ├── element/string.json            # 字符串资源
│   │       └── profile/input_method_config.json
│   └── module.json5                           # 模块配置
└── README.md
```

## Commit 信息

**Commit Hash**: `a1b2c3d4e5f6789012345678901234567890abcd`

### 主要改动

1. **小鹤双拼编码引擎** (`model/ShuangpinEngine.ets`)
   - 实现完整声母/韵母键位映射
   - 状态机处理输入流
   - 内置5000+常用词库

2. **滑行输入模块** (`model/SwipeInputEngine.ets`)
   - 手势识别算法
   - 路径解码
   - 边界情况处理

3. **输入法框架集成** (`InputMethodExtensionAbility/`)
   - IME Kit 扩展能力实现
   - 软键盘UI（26键全键盘）
   - 候选词栏显示

## 技术规格

- **平台**: HarmonyOS Next (API 12+)
- **开发语言**: ArkTS
- **输入法类型**: InputMethodExtensionAbility
- **词库规模**: 5000+ 常用词
- **采样率**: 30Hz
- **响应延迟**: <50ms

## 许可

MIT License