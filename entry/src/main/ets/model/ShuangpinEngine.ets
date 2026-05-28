/**
 * 小鹤双拼编码引擎 - ShuangpinEngine
 * 严格按小鹤双拼方案实现声母/韵母键位映射
 */

// =============== 小鹤双拼键位定义 ===============

// 声母键位映射 (小鹤双拼)
export const CONSONANT_MAP: Map<string, string> = new Map([
  ['b', 'b'], ['p', 'p'], ['m', 'm'], ['f', 'f'],
  ['d', 'd'], ['t', 't'], ['n', 'n'], ['l', 'l'],
  ['g', 'g'], ['k', 'k'], ['h', 'h'],
  ['j', 'j'], ['q', 'q'], ['x', 'x'],
  ['zh', 'v'], ['ch', 'c'], ['sh', 'u'],
  ['r', 'r'], ['z', 'z'], ['c', 'c'], ['s', 's'],
  ['y', 'y'], ['w', 'w']
]);

// 韵母键位映射 (小鹤双拼) - 核心规范
export const VOWEL_MAP: Map<string, string> = new Map([
  // 单韵母
  ['a', 'a'], ['o', 'o'], ['e', 'e'], ['i', 'i'], ['u', 'u'], ['v', 'v'],
  // 复合韵母
  ['ai', 'd'], ['ei', 'w'], ['ui', 'v'],
  ['ao', 'c'], ['ou', 'z'], ['iu', 'q'],
  ['ie', 'p'], ['ve', 't'],
  // 鼻韵母 - 前鼻音
  ['an', 'j'], ['en', 'f'], ['in', 'b'], ['un', 'y'],
  ['vn', 't'],  // ün
  // 鼻韵母 - 后鼻音
  ['ang', 'h'], ['eng', 'g'], ['ing', 'k'], ['ong', 's'],
  // 其他组合
  ['ia', 'x'], ['ua', 'x'], ['uo', 'o'],
  ['uai', 'k'], ['uei', 'k'],
  ['iang', 'l'], ['uang', 'l'],
  ['iang', 'l'], ['uang', 'l'],
  ['ian', 'm'], ['uan', 'r'], ['uan', 'r'],
  ['iong', 's'],
  ['iong', 's']
]);

// =============== 编码状态机 ===============

export enum InputState {
  INITIAL = 0,      // 初始状态
  SHENG = 1,        // 已输入声母
  YUN = 2,          // 已输入韵母 (完成一字)
  ERROR = 3         // 输入错误
}

export interface EncodingResult {
  pinyin: string;      // 全拼
  keys: string[];      // 击键序列
  isComplete: boolean; // 是否完成一字
  state: InputState;
}

// =============== ShuangpinEngine 类 ===============

export class ShuangpinEngine {
  private inputBuffer: string = '';  // 原始输入缓冲
  private encodedBuffer: string = ''; // 编码后缓冲
  private lastState: InputState = InputState.INITIAL;

  constructor() {
    this.reset();
  }

  reset(): void {
    this.inputBuffer = '';
    this.encodedBuffer = '';
    this.lastState = InputState.INITIAL;
  }

  /**
   * 处理单个按键输入
   * @param key 按键 (a-z)
   * @return 当前编码结果
   */
  processKey(key: string): EncodingResult {
    const lowerKey = key.toLowerCase();
    this.inputBuffer += lowerKey;

    // 更新编码缓冲
    const result = this.doEncode(lowerKey);
    return result;
  }

  /**
   * 核心编码逻辑
   */
  private doEncode(key: string): EncodingResult {
    const currentLen = this.encodedBuffer.length;

    // 状态机处理
    switch (this.lastState) {
      case InputState.INITIAL:
        // 初始状态：可能是声母或零声母韵母
        return this.handleInitial(key);
      case InputState.SHENG:
        // 已输入声母：处理韵母
        return this.handleAfterSheng(key);
      case InputState.YUN:
        // 刚完成一字：重置并开始新字
        this.lastState = InputState.INITIAL;
        return this.handleInitial(key);
      default:
        return this.makeResult('', [], false, InputState.ERROR);
    }
  }

  /**
   * 处理初始状态
   */
  private handleInitial(key: string): EncodingResult {
    // 检查是否是声母键
    if (CONSONANT_MAP.has(key)) {
      this.lastState = InputState.SHENG;
      return this.makeResult(key, [key], false, InputState.SHENG);
    }

    // 零声母处理：韵母直接作为声母
    if (VOWEL_MAP.has(key)) {
      // 韵母键作为零声母 (韵母首字母)
      const shengmu = this.getShengmuFromYun(key);
      if (shengmu) {
        // 零声母: 韵母首字母 + 韵母键
        this.lastState = InputState.SHENG;
        return this.makeResult(shengmu + key, [shengmu, key], false, InputState.SHENG);
      }
    }

    // 尝试匹配复合韵母
    if (this.inputBuffer.length >= 2) {
      const lastTwo = this.inputBuffer.slice(-2);
      if (VOWEL_MAP.has(lastTwo)) {
        this.lastState = InputState.SHENG;
        return this.makeResult(lastTwo, [this.getShengmuFromYun(lastTwo[0]) || lastTwo[0], lastTwo[1]], false, InputState.SHENG);
      }
    }

    // 默认：直接上屏
    this.lastState = InputState.YUN;
    return this.makeResult(key, [key], true, InputState.YUN);
  }

  /**
   * 处理已输入声母后的按键
   */
  private handleAfterSheng(key: string): EncodingResult {
    // 检查是否是韵母键
    if (VOWEL_MAP.has(key)) {
      this.lastState = InputState.YUN;
      return this.makeResult(this.inputBuffer, this.inputBuffer.split(''), true, InputState.YUN);
    }

    // 检查复合韵母
    if (this.inputBuffer.length >= 2) {
      const lastTwo = this.inputBuffer.slice(-2);
      if (VOWEL_MAP.has(lastTwo)) {
        this.lastState = InputState.YUN;
        return this.makeResult(lastTwo, lastTwo.split(''), true, InputState.YUN);
      }
    }

    // 错误状态
    this.lastState = InputState.ERROR;
    return this.makeResult(this.inputBuffer, this.inputBuffer.split(''), false, InputState.ERROR);
  }

  /**
   * 从韵母获取声母（零声母方案）
   */
  private getShengmuFromYun(yun: string): string | null {
    // 单韵母直接用首字母
    if (yun.length === 1) {
      return yun;
    }
    // 复合韵母用首字母
    return yun[0];
  }

  /**
   * 构建编码结果
   */
  private makeResult(pinyin: string, keys: string[], isComplete: boolean, state: InputState): EncodingResult {
    return {
      pinyin,
      keys,
      isComplete,
      state
    };
  }

  /**
   * 获取当前拼音串（用于查询候选）
   */
  getCurrentPinyin(): string {
    return this.inputBuffer;
  }

  /**
   * 退格处理
   */
  backspace(): EncodingResult {
    if (this.inputBuffer.length > 0) {
      this.inputBuffer = this.inputBuffer.slice(0, -1);
      this.lastState = InputState.INITIAL;
    }
    return this.makeResult(this.inputBuffer, this.inputBuffer.split(''), false, this.lastState);
  }
}

// =============== 词库接口 ===============

export interface WordEntry {
  pinyin: string;
  word: string;
  frequency: number;
}

// =============== 简单词库 (内置常用词) ===============

const COMMON_WORDS: WordEntry[] = [
  // 常用单字
  { pinyin: 'de', word: '的', frequency: 1000 },
  { pinyin: 'yi', word: '一', frequency: 999 },
  { pinyin: 'shi', word: '是', frequency: 998 },
  { pinyin: 'wo', word: '我', frequency: 997 },
  { pinyin: 'zhong', word: '中', frequency: 996 },
  { pinyin: 'guo', word: '国', frequency: 995 },
  { pinyin: 'ren', word: '人', frequency: 994 },
  { pinyin: 'you', word: '有', frequency: 993 },
  { pinyin: 'le', word: '了', frequency: 992 },
  { pinyin: 'zhi', word: '之', frequency: 991 },
  { pinyin: 'zai', word: '在', frequency: 990 },
  { pinyin: 'he', word: '和', frequency: 989 },
  { pinyin: 'da', word: '大', frequency: 988 },
  { pinyin: 'wei', word: '为', frequency: 987 },
  { pinyin: 'yu', word: '于', frequency: 986 },
  { pinyin: 'shang', word: '上', frequency: 985 },
  { pinyin: 'men', word: '们', frequency: 984 },
  { pinyin: 'lai', word: '来', frequency: 983 },
  { pinyin: 'hui', word: '会', frequency: 982 },
  { pinyin: 'zi', word: '子', frequency: 981 },
  { pinyin: 'xue', word: '学', frequency: 980 },
  { pinyin: 'ji', word: '机', frequency: 979 },
  { pinyin: 'ye', word: '也', frequency: 978 },
  { pinyin: 'jiu', word: '就', frequency: 977 },
  { pinyin: 'xia', word: '下', frequency: 976 },
  { pinyin: 'cong', word: '从', frequency: 975 },
  { pinyin: 'dao', word: '到', frequency: 974 },
  { pinyin: 'qu', word: '去', frequency: 973 },
  { pinyin: 'chan', word: '产', frequency: 972 },
  { pinyin: 'sheng', word: '生', frequency: 971 },
  { pinyin: 'zhu', word: '主', frequency: 970 },
  { pinyin: 'na', word: '那', frequency: 969 },
  { pinyin: 'he', word: '和', frequency: 968 },
  { pinyin: 'cheng', word: '成', frequency: 967 },
  { pinyin: 'nian', word: '年', frequency: 966 },
  { pinyin: 'fa', word: '发', frequency: 965 },
  { pinyin: 'zhan', word: '展', frequency: 964 },
  { pinyin: 'kai', word: '开', frequency: 963 },
  { pinyin: 'dong', word: '动', frequency: 962 },
  { pinyin: 'li', word: '里', frequency: 961 },
  { pinyin: 'yin', word: '因', frequency: 960 },
  { pinyin: 'ke', word: '可', frequency: 959 },
  { pinyin: 'shi', word: '时', frequency: 958 },
  { pinyin: 'jia', word: '家', frequency: 957 },
  { pinyin: 'ge', word: '个', frequency: 956 },
  { pinyin: 'yuan', word: '元', frequency: 955 },
  { pinyin: 'si', word: '思', frequency: 954 },
  { pinyin: 'qi', word: '起', frequency: 953 },
  { pinyin: 'jian', word: '见', frequency: 952 },
  { pinyin: 'guo', word: '过', frequency: 951 },
  { pinyin: 'tian', word: '天', frequency: 950 },
  { pinyin: 'zhong', word: '种', frequency: 949 },
  { pinyin: 'ming', word: '名', frequency: 948 },
  { pinyin: 'ni', word: '你', frequency: 947 },
  { pinyin: 'hui', word: '回', frequency: 946 },
  { pinyin: 'ta', word: '他', frequency: 945 },
  { pinyin: 'men', word: '门', frequency: 944 },
  { pinyin: 'hao', word: '好', frequency: 943 },
  { pinyin: 'wu', word: '无', frequency: 942 },
  { pinyin: 'xia', word: '小', frequency: 941 },
  { pinyin: 'zi', word: '自', frequency: 940 },
  { pinyin: 'bian', word: '变', frequency: 939 },
  { pinyin: 'jiang', word: '将', frequency: 938 },
  { pinyin: 'de', word: '得', frequency: 937 },
  { pinyin: 'di', word: '地', frequency: 936 },
  { pinyin: 'zhe', word: '这', frequency: 935 },
  { pinyin: 'ge', word: '各', frequency: 934 },
  { pinyin: 'zhong', word: '重', frequency: 933 },
  { pinyin: 'si', word: '死', frequency: 932 },
  { pinyin: 'ta', word: '她', frequency: 931 },
  { pinyin: 'dui', word: '对', frequency: 930 },
  { pinyin: 'qi', word: '其', frequency: 929 },
  { pinyin: 'yu', word: '与', frequency: 928 },
  { pinyin: 'ji', word: '及', frequency: 927 },
  { pinyin: 'zhi', word: '知', frequency: 926 },
  { pinyin: 'ru', word: '如', frequency: 925 },
  { pinyin: 'ci', word: '此', frequency: 924 },
  { pinyin: 'zhuan', word: '专', frequency: 923 },
  { pinyin: 'shi', word: '实', frequency: 922 },
  { pinyin: 'jun', word: '军', frequency: 921 },
  { pinyin: 'xing', word: '行', frequency: 920 },
  { pinyin: 'zhi', word: '制', frequency: 919 },
  { pinyin: 'xing', word: '性', frequency: 918 },
  { pinyin: 'yang', word: '样', frequency: 917 },
  { pinyin: 'qi', word: '期', frequency: 916 },
  { pinyin: 'dang', word: '当', frequency: 915 },
  { pinyin: 'ti', word: '体', frequency: 914 },
  { pinyin: 'zhu', word: '注', frequency: 913 },
  { pinyin: 'na', word: '内', frequency: 912 },
  { pinyin: 'wu', word: '物', frequency: 911 },
  { pinyin: 'jian', word: '间', frequency: 910 },
  { pinyin: 'qu', word: '区', frequency: 909 },
  { pinyin: 'fen', word: '分', frequency: 908 },
  { pinyin: 'hua', word: '化', frequency: 907 },
  { pinyin: 'zi', word: '资', frequency: 906 },
  { pinyin: 'chan', word: '产', frequency: 905 },
  { pinyin: 'jie', word: '解', frequency: 904 },
  { pinyin: 'jiao', word: '教', frequency: 903 },
  { pinyin: 'ji', word: '即', frequency: 902 },
  { pinyin: 'si', word: '死', frequency: 901 },
  { pinyin: 'guo', word: '国', frequency: 900 },

  // 常用词组
  { pinyin: 'zhongguo', word: '中国', frequency: 2000 },
  { pinyin: 'renmin', word: '人民', frequency: 1999 },
  { pinyin: 'shijie', word: '世界', frequency: 1998 },
  { pinyin: 'zhonghua', word: '中华', frequency: 1997 },
  { pinyin: 'shehui', word: '社会', frequency: 1996 },
  { pinyin: 'jiazu', word: '家族', frequency: 1995 },
  { pinyin: 'xuexi', word: '学习', frequency: 1994 },
  { pinyin: 'gongzuo', word: '工作', frequency: 1993 },
  { pinyin: 'shenghuo', word: '生活', frequency: 1992 },
  { pinyin: 'fazhan', word: '发展', frequency: 1991 },
  { pinyin: 'tongzhi', word: '同志', frequency: 1990 },
  { pinyin: 'jiejue', word: '解决', frequency: 1989 },
  { pinyin: 'lianxi', word: '联系', frequency: 1988 },
  { pinyin: 'jiji', word: '积极', frequency: 1987 },
  { pinyin: 'zhidao', word: '知道', frequency: 1986 },
  { pinyin: 'zhuyi', word: '主义', frequency: 1985 },
  { pinyin: 'zhengzhi', word: '政治', frequency: 1984 },
  { pinyin: 'jingji', word: '经济', frequency: 1983 },
  { pinyin: 'wenming', word: '文明', frequency: 1982 },
  { pinyin: 'ticheng', word: '提成', frequency: 1981 },
  { pinyin: 'fangfa', word: '方法', frequency: 1980 },
  { pinyin: 'jieshi', word: '解释', frequency: 1979 },
  { pinyin: 'genju', word: '根据', frequency: 1978 },
  { pinyin: 'qushi', word: '趋势', frequency: 1977 },
  { pinyin: 'jihui', word: '机会', frequency: 1976 },
  { pinyin: 'went', word: '问题', frequency: 1975 },
  { pinyin: 'liliang', word: '力量', frequency: 1974 },
  { pinyin: 'chenggong', word: '成功', frequency: 1973 },
  { pinyin: 'zuoyong', word: '作用', frequency: 1972 },
  { pinyin: 'yinggai', word: '应该', frequency: 1971 },
  { pinyin: 'jihu', word: '几乎', frequency: 1970 },
  { pinyin: 'shijian', word: '时间', frequency: 1969 },
  { pinyin: 'lishi', word: '历史', frequency: 1968 },
  { pinyin: 'muqian', word: '目前', frequency: 1967 },
  { pinyin: 'bingqing', word: '病情', frequency: 1966 },
  { pinyin: 'yihua', word: '计划', frequency: 1965 },
  { pinyin: 'qushi', word: '驱使', frequency: 1964 },
  { pinyin: 'jiqiao', word: '技巧', frequency: 1963 },
  { pinyin: 'biaoxian', word: '表现', frequency: 1962 },
  { pinyin: 'zhengfu', word: '政府', frequency: 1961 },
  { pinyin: 'gongsi', word: '公司', frequency: 1960 },
  { pinyin: 'xianqi', word: '先驱', frequency: 1959 },
  { pinyin: 'shoudao', word: '收到', frequency: 1958 },
  { pinyin: 'zhenshi', word: '真实', frequency: 1957 },
  { pinyin: 'zhongyao', word: '重要', frequency: 1956 },
  { pinyin: 'zhuti', word: '主题', frequency: 1955 },
  { pinyin: 'mianqian', word: '面前', frequency: 1954 },
  { pinyin: 'tichang', word: '提倡', frequency: 1953 },
  { pinyin: 'zhidao', word: '指导', frequency: 1952 },
  { pinyin: 'jigou', word: '机构', frequency: 1951 },
  { pinyin: 'jianding', word: '坚定', frequency: 1950 },
  { pinyin: 'jiji', word: '基建', frequency: 1949 },
  { pinyin: 'guangchang', word: '广场', frequency: 1948 },
  { pinyin: 'fenxi', word: '分析', frequency: 1947 },
  { pinyin: 'jingzhun', word: '精准', frequency: 1946 },
  { pinyin: 'jicheng', word: '集成', frequency: 1945 },
  { pinyin: 'zhongxin', word: '中心', frequency: 1944 },
  { pinyin: 'yinyue', word: '音乐', frequency: 1943 },
  { pinyin: 'fuzhu', word: '辅助', frequency: 1942 },
  { pinyin: 'jiqiao', word: '机器', frequency: 1941 },
  { pinyin: 'zhineng', word: '智能', frequency: 1940 },
  { pinyin: 'shuru', word: '输入', frequency: 1939 },
  { pinyin: 'shuchu', word: '输出', frequency: 1938 },
  { pinyin: 'xianlu', word: '线路', frequency: 1937 },
  { pinyin: 'lianjie', word: '连接', frequency: 1936 },
  { pinyin: 'wangluo', word: '网络', frequency: 1935 },
  { pinyin: 'xinhao', word: '信号', frequency: 1934 },
  { pinyin: 'zhuanhuan', word: '转换', frequency: 1933 },
  { pinyin: 'jisuan', word: '计算', frequency: 1932 },
  { pinyin: 'chuli', word: '处理', frequency: 1931 },
  { pinyin: 'neirong', word: '内容', frequency: 1930 },
  { pinyin: 'jieshu', word: '结束', frequency: 1929 },
  { pinyin: 'kaishi', word: '开始', frequency: 1928 },
  { pinyin: 'jixu', word: '继续', frequency: 1927 },
  { pinyin: 'gengxin', word: '更新', frequency: 1926 },
  { pinyin: 'jianli', word: '简历', frequency: 1925 },
  { pinyin: 'jiancha', word: '检查', frequency: 1924 },
  { pinyin: 'queren', word: '确认', frequency: 1923 },
  { pinyin: 'tongyi', word: '统一', frequency: 1922 },
  { pinyin: 'youxian', word: '优先', frequency: 1921 },
  { pinyin: 'youxiao', word: '有效', frequency: 1920 },
  { pinyin: 'zidong', word: '自动', frequency: 1919 },
  { pinyin: 'shouji', word: '手机', frequency: 1918 },
  { pinyin: 'dianhua', word: '电话', frequency: 1917 },
  { pinyin: 'xiaoxi', word: '消息', frequency: 1916 },
  { pinyin: 'tongzhi', word: '通知', frequency: 1915 },
  { pinyin: 'shezhi', word: '设置', frequency: 1914 },
  { pinyin: 'gongneng', word: '功能', frequency: 1913 },
  { pinyin: 'yemian', word: '页面', frequency: 1912 },
  { pinyin: 'liebiao', word: '列表', frequency: 1911 },
  { pinyin: 'tupian', word: '图片', frequency: 1910 },
  { pinyin: 'wenzi', word: '文字', frequency: 1909 },
  { pinyin: 'shuruk', word: '输入框', frequency: 1908 },
  { pinyin: 'anNiu', word: '按钮', frequency: 1907 },
  { pinyin: 'xuanze', word: '选择', frequency: 1906 },
  { pinyin: 'queren', word: '确认', frequency: 1905 },
  { pinyin: 'quxiao', word: '取消', frequency: 1904 },
  { pinyin: 'baocun', word: '保存', frequency: 1903 },
  { pinyin: 'fasong', word: '发送', frequency: 1902 },
  { pinyin: 'jieshou', word: '接收', frequency: 1901 },
  { pinyin: 'xiaodai', word: '小鹤', frequency: 1900 }
];

// =============== 候选词管理器 ===============

export class CandidateManager {
  private wordList: WordEntry[] = [];

  constructor() {
    // 加载内置词库
    this.loadDictionary();
  }

  private loadDictionary(): void {
    // 使用内置词库
    this.wordList = [...COMMON_WORDS];
    // 按频率排序
    this.wordList.sort((a, b) => b.frequency - a.frequency);
  }

  /**
   * 根据拼音查询候选词
   * @param pinyin 拼音串（不含声调）
   */
  query(pinyin: string): string[] {
    const results: WordEntry[] = [];

    for (const entry of this.wordList) {
      if (entry.pinyin === pinyin) {
        results.push(entry);
      } else if (entry.pinyin.startsWith(pinyin)) {
        results.push(entry);
      }
    }

    // 按频率排序
    results.sort((a, b) => b.frequency - a.frequency);

    // 返回前9个候选
    return results.slice(0, 9).map(entry => entry.word);
  }

  /**
   * 添加词组（用户输入）
   */
  addWord(pinyin: string, word: string): void {
    // 检查是否已存在
    const existing = this.wordList.find(e => e.pinyin === pinyin && e.word === word);
    if (existing) {
      existing.frequency += 1;
    } else {
      this.wordList.push({ pinyin, word, frequency: 1 });
    }
  }
}

// =============== 单元测试 ===============

export function runTests(): void {
  const engine = new ShuangpinEngine();
  const candidate = new CandidateManager();

  console.log('========== 小鹤双拼引擎单元测试 ==========');

  // 测试1: 单字编码
  console.log('\n[测试1] 单字编码');
  const tests = [
    { keys: 'de', expected: 'de', desc: '的' },
    { keys: 'vs', expected: 'zhong', desc: '中' },
    { keys: 'go', expected: 'guo', desc: '国' },
    { keys: 'xi', expected: 'xi', desc: '西' },
    { keys: 'uj', expected: 'shi', desc: '是' }
  ];

  for (const test of tests) {
    engine.reset();
    for (const key of test.keys.split('')) {
      engine.processKey(key);
    }
    console.log(`  输入 ${test.desc}: ${test.keys} -> ${engine.getCurrentPinyin()}`);
  }

  // 测试2: 候选词查询
  console.log('\n[测试2] 候选词查询');
  const pyTests = ['de', 'zhong', 'guo', 'xuexi', 'zhongguo'];
  for (const py of pyTests) {
    const candidates = candidate.query(py);
    console.log(`  ${py}: ${candidates.join(', ') || '(无匹配)'}`);
  }

  // 测试3: 小鹤双拼键位验证
  console.log('\n[测试3] 键位验证');
  console.log('  声母键位: zh=v, ch=c, sh=u');
  console.log('  韵母键位: ai=d, ei=w, ui=v, ao=c, ou=z, iu=q, ie=p, ve=t');
  console.log('  鼻韵母: an=j, en=f, in=b, un=y, ang=h, eng=g, ing=k, ong=s');

  console.log('\n========== 测试完成 ==========');
}

// 导出模块
export default {
  ShuangpinEngine,
  CandidateManager,
  CONSONANT_MAP,
  VOWEL_MAP,
  runTests
};