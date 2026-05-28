# 小鹤双拼输入法 for HarmonyOS Next

一款基于鸿蒙 Next 平台的小鹤双拼输入法应用，采用 ArkTS 开发，实现了完整的小鹤双拼编码引擎、候选词系统和软键盘 UI。

## 功能特性

- **小鹤双拼编码**: 完整实现小鹤双拼键位映射，支持声母韵母双键输入
- **智能候选**: 内置常用词库，支持按频率排序的数字选字（1-9）
- **滑行输入**: 支持在虚拟键盘上滑行输入，路径解码为按键序列
- **双拼模式**: 严格遵循小鹤双拼规范，支持零声母处理

## 小鹤双拼键位表

### 声母键位

| 声母 | 键位 |
|------|------|
| b, p, m, f, d, t, n, l | 原键位 |
| g, k, h | 原键位 |
| j, q, x | 原键位 |
| zh | **V** |
| ch | **C** |
| sh | **U** |
| r, z, c, s | 原键位 |
| y, w | 原键位 |

### 韵母键位

| 韵母 | 键位 | 韵母 | 键位 |
|------|------|------|------|
| a | a | o | o |
| e | e | i | i |
| u | u | v (ü) | v |
| ai | **D** | ei | **W** |
| ui | **V** | ao | **C** |
| ou | **Z** | iu | **Q** |
| ie | **P** | ve (üe) | **T** |
| an | **J** | en | **F** |
| in | **B** | un | **Y** |
| ang | **H** | eng | **G** |
| ing | **K** | ong | **S** |

### 常用字编码示例

| 汉字 | 小鹤双拼 | 说明 |
|------|----------|------|
| 的 | de | d + e |
| 中 | vs | v(s) + s(ong) |
| 国 | go | g + o |
| 学 | xt | x + t |
| 习 | xi | x + i |
| 中国 | vsgo | vsc + gol |
| 学习 | xtxi | xt + xi |

## 项目结构

```
he-pinyin-ime/
├── entry/
│   └── src/
│       └── main/
│           ├── ets/
│           │   ├── InputMethodExtensionAbility/   # 输入法扩展能力
│           │   │   ├── InputMethodService.ets     # 输入法服务入口
│           │   │   ├── model/
│           │   │   │   ├── KeyboardController.ets # 键盘控制器
│           │   │   │   ├── InputHandler.ets       # 输入处理器
│           │   │   │   └── KeyboardKeyData.ets    # 按键数据定义
│           │   │   └── pages/
│           │   │       └── Index.ets              # 键盘主页面
│           │   ├── model/                          # 核心模块
│           │   │   ├── ShuangpinEngine.ets         # 双拼编码引擎
│           │   │   ├── SwipeInputEngine.ets        # 滑行输入引擎
│           │   │   └── Log.ets                    # 日志工具
│           │   ├── common/                         # 公共组件
│           │   │   └── StyleConfiguration.ets      # 样式配置
│           │   └── components/                      # UI组件
│           ├── resources/
│           │   └── base/
│           │       ├── element/                    # 字符串资源
│           │       └── profile/                    # 输入法配置
│           └── module.json5                        # 模块配置
└── package.json
```

## 技术架构

### 模块说明

1. **ShuangpinEngine** (`model/ShuangpinEngine.ets`)
   - 小鹤双拼编码引擎
   - 声母/韵母键位映射
   - 状态机处理输入流
   - 候选词管理（CandidateManager）

2. **SwipeInputEngine** (`model/SwipeInputEngine.ets`)
   - 滑行手势识别
   - 路径解码
   - 边界情况处理（抖动、U形、快速滑出）
   - 性能优化（30Hz采样率）

3. **KeyboardController** (`InputMethodExtensionAbility/model/KeyboardController.ets`)
   - 输入法生命周期管理
   - 面板创建和销毁
   - 事件监听注册

4. **Index.ets** (`InputMethodExtensionAbility/pages/Index.ets`)
   - 软键盘UI实现
   - 候选词栏
   - 按键事件处理

## 安装和测试

### 环境要求

- DevEco Studio 4.0+
- HarmonyOS SDK API 12+
- Node.js 18+ (用于开发辅助)

### 构建步骤

1. 使用 DevEco Studio 打开项目
2. 连接 HarmonyOS 设备或模拟器
3. 构建并运行

### 测试说明

运行引擎单元测试验证编码正确性：

```typescript
import { runTests } from './model/ShuangpinEngine';
runTests();
```

## 编码规范

- 使用 ArkTS 进行开发
- 遵循 HarmonyOS Stage 模型
- 模块化设计，职责分离
- 统一的日志输出

## 许可

MIT License

## 参考资料

- [小鹤双拼官网](http://flypy.ys168.com/)
- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/)
- [IME Kit 开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/)

---

**声明**: 本项目仅供学习研究使用，小鹤双拼方案版权归原作者所有。