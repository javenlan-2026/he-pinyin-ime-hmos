/**
 * 滑行输入模块 - SwipeInputEngine
 * 基于单键手势识别的滑行输入实现
 */

import { KeyPosition } from './KeyPosition';

// =============== 手势点 ===============

export interface GesturePoint {
  x: number;        // X坐标
  y: number;        // Y坐标
  timestamp: number; // 时间戳 (ms)
  keyIndex?: number; // 触发的按键索引
}

// =============== 滑行路径 ===============

export interface SwipePath {
  points: GesturePoint[];  // 路径点序列
  duration: number;        // 总时长 (ms)
  keys: string[];          // 识别出的按键序列
}

// =============== 滑行输入引擎 ===============

export class SwipeInputEngine {
  private isSwiping: boolean = false;
  private currentPath: GesturePoint[] = [];
  private startTime: number = 0;

  // 性能参数
  private readonly MIN_SWIPE_POINTS: number = 3;     // 最少采样点
  private readonly POINT_SAMPLING_RATE: number = 33; // 采样间隔 (ms) ~30Hz
  private readonly MAX_SWIPE_TIME: number = 2000;    // 最大滑行时长 (ms)
  private readonly MIN_SWIPE_DISTANCE: number = 10;  // 最小滑动距离

  // 按键位置映射
  private keyPositions: KeyPosition[] = [];

  constructor(keyPositions: KeyPosition[] = []) {
    this.keyPositions = keyPositions;
  }

  /**
   * 设置按键位置映射
   */
  setKeyPositions(positions: KeyPosition[]): void {
    this.keyPositions = positions;
  }

  /**
   * 开始滑行
   */
  startSwipe(x: number, y: number): void {
    this.isSwiping = true;
    this.currentPath = [{
      x,
      y,
      timestamp: Date.now(),
      keyIndex: this.findKeyAtPosition(x, y)
    }];
    this.startTime = Date.now();
  }

  /**
   * 添加滑行点
   */
  addSwipePoint(x: number, y: number): void {
    if (!this.isSwiping) return;

    const now = Date.now();
    const elapsed = now - this.startTime;

    // 检查是否超时
    if (elapsed > this.MAX_SWIPE_TIME) {
      this.endSwipe();
      return;
    }

    // 检查采样间隔（性能优化）
    const lastPoint = this.currentPath[this.currentPath.length - 1];
    if (lastPoint && now - lastPoint.timestamp < this.POINT_SAMPLING_RATE) {
      return;
    }

    // 添加新点
    const keyIndex = this.findKeyAtPosition(x, y);
    this.currentPath.push({
      x,
      y,
      timestamp: now,
      keyIndex
    });
  }

  /**
   * 结束滑行
   */
  endSwipe(): SwipePath | null {
    if (!this.isSwiping || this.currentPath.length < this.MIN_SWIPE_POINTS) {
      this.reset();
      return null;
    }

    const path = this.decodePath();
    this.reset();
    return path;
  }

  /**
   * 取消滑行
   */
  cancelSwipe(): void {
    this.reset();
  }

  /**
   * 重置状态
   */
  private reset(): void {
    this.isSwiping = false;
    this.currentPath = [];
    this.startTime = 0;
  }

  /**
   * 根据坐标查找按键索引
   */
  private findKeyAtPosition(x: number, y: number): number {
    if (this.keyPositions.length === 0) return -1;

    let nearestIndex = -1;
    let nearestDistance = Infinity;

    for (let i = 0; i < this.keyPositions.length; i++) {
      const key = this.keyPositions[i];
      const dx = x - key.centerX;
      const dy = y - key.centerY;
      const distance = Math.sqrt(dx * dx + dy * dy);

      // 检查是否在按键范围内
      if (distance < key.width / 2 && distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  /**
   * 解码滑行路径
   */
  private decodePath(): SwipePath {
    // 提取按过的键（去重）
    const keySet = new Set<number>();
    for (const point of this.currentPath) {
      if (point.keyIndex >= 0) {
        keySet.add(point.keyIndex);
      }
    }

    // 转换为键字符序列
    const keys: string[] = [];
    for (const index of keySet) {
      if (this.keyPositions[index]) {
        keys.push(this.keyPositions[index].key);
      }
    }

    // 计算总时长
    const duration = this.currentPath.length > 0
      ? this.currentPath[this.currentPath.length - 1].timestamp - this.currentPath[0].timestamp
      : 0;

    return {
      points: [...this.currentPath],
      duration,
      keys
    };
  }

  /**
   * 检查是否是有效滑行
   */
  isValidSwipe(): boolean {
    if (this.currentPath.length < this.MIN_SWIPE_POINTS) {
      return false;
    }

    // 计算总距离
    let totalDistance = 0;
    for (let i = 1; i < this.currentPath.length; i++) {
      const dx = this.currentPath[i].x - this.currentPath[i - 1].x;
      const dy = this.currentPath[i].y - this.currentPath[i - 1].y;
      totalDistance += Math.sqrt(dx * dx + dy * dy);
    }

    return totalDistance >= this.MIN_SWIPE_DISTANCE;
  }

  /**
   * 获取当前滑行状态
   */
  getCurrentKeys(): string[] {
    const keySet = new Set<number>();
    for (const point of this.currentPath) {
      if (point.keyIndex >= 0) {
        keySet.add(point.keyIndex);
      }
    }
    return Array.from(keySet).map(i => this.keyPositions[i]?.key || '');
  }

  /**
   * 获取滑行轨迹（用于可视化）
   */
  getPathPoints(): GesturePoint[] {
    return [...this.currentPath];
  }

  /**
   * 性能指标
   */
  getPerformanceMetrics(): { pointCount: number; duration: number; samplingRate: number } {
    const duration = this.currentPath.length > 0
      ? this.currentPath[this.currentPath.length - 1].timestamp - this.currentPath[0].timestamp
      : 0;
    const samplingRate = duration > 0 ? (this.currentPath.length / duration) * 1000 : 0;

    return {
      pointCount: this.currentPath.length,
      duration,
      samplingRate: Math.round(samplingRate)
    };
  }
}

// =============== 按键位置定义 ===============

export interface KeyPosition {
  key: string;       // 按键字符
  centerX: number;   // 中心X坐标
  centerY: number;  // 中心Y坐标
  width: number;    // 按键宽度
  height: number;   // 按键高度
  row: number;       // 行号 (0-based)
  col: number;       // 列号 (0-based)
}

// =============== 边界情况处理 ===============

export enum EdgeCaseType {
  QUICK_SWIPE = 'quick_swipe',      // 快速滑出
  SHAKE = 'shake',                   // 抖动
  U_SHAPE = 'u_shape',              // U形滑行
  LONG_PRESS = 'long_press',        // 长按
  NORMAL = 'normal'                 // 正常
}

export class EdgeCaseHandler {
  private readonly QUICK_SWIPE_THRESHOLD: number = 200;  // 快速滑行阈值 (ms)
  private readonly SHAKE_THRESHOLD: number = 50;         // 抖动阈值 (像素)
  private readonly SHAKE_COUNT: number = 3;              // 抖动次数

  /**
   * 检测边界情况
   */
  detectEdgeCase(path: SwipePath): EdgeCaseType {
    // 快速滑出
    if (path.duration < this.QUICK_SWIPE_THRESHOLD && path.points.length < 5) {
      return EdgeCaseType.QUICK_SWIPE;
    }

    // 抖动检测
    if (this.detectShake(path)) {
      return EdgeCaseType.SHAKE;
    }

    // U形滑行检测
    if (this.detectUShape(path)) {
      return EdgeCaseType.U_SHAPE;
    }

    return EdgeCaseType.NORMAL;
  }

  /**
   * 检测抖动
   */
  private detectShake(path: SwipePath): boolean {
    if (path.points.length < this.SHAKE_COUNT * 2) return false;

    let directionChanges = 0;
    let lastDx = 0;
    let lastDy = 0;

    for (let i = 1; i < path.points.length; i++) {
      const dx = path.points[i].x - path.points[i - 1].x;
      const dy = path.points[i].y - path.points[i - 1].y;

      // 方向变化
      if (lastDx !== 0 && lastDy !== 0) {
        if (dx * lastDx < 0 || dy * lastDy < 0) {
          const dist = Math.sqrt((dx - lastDx) ** 2 + (dy - lastDy) ** 2);
          if (dist < this.SHAKE_THRESHOLD) {
            directionChanges++;
          }
        }
      }

      lastDx = dx;
      lastDy = dy;
    }

    return directionChanges >= this.SHAKE_COUNT;
  }

  /**
   * 检测U形滑行
   */
  private detectUShape(path: SwipePath): boolean {
    if (path.points.length < 10) return false;

    const first = path.points[0];
    const last = path.points[path.points.length - 1];
    const middle = path.points[Math.floor(path.points.length / 2)];

    // 检查首尾距离和中间点位置
    const firstLastDist = Math.sqrt((last.x - first.x) ** 2 + (last.y - first.y) ** 2);
    const firstMiddleDist = Math.sqrt((middle.x - first.x) ** 2 + (middle.y - first.y) ** 2);

    // U形: 首尾较近，但中间点与首尾有较大距离
    return firstLastDist < firstMiddleDist * 0.5;
  }

  /**
   * 处理边界情况
   */
  handleEdgeCase(path: SwipePath, edgeCase: EdgeCaseType): SwipePath {
    switch (edgeCase) {
      case EdgeCaseType.QUICK_SWIPE:
        // 只保留最后一个键
        return {
          ...path,
          keys: path.keys.slice(-1)
        };
      case EdgeCaseType.SHAKE:
        // 只保留主方向上的键
        return this.extractMainDirectionKeys(path);
      case EdgeCaseType.U_SHAPE:
        // 去除重复键
        return {
          ...path,
          keys: [...new Set(path.keys)]
        };
      default:
        return path;
    }
  }

  /**
   * 提取主方向键
   */
  private extractMainDirectionKeys(path: SwipePath): SwipePath {
    if (path.points.length < 2) return path;

    // 计算主方向
    const first = path.points[0];
    const last = path.points[path.points.length - 1];
    const dX = last.x - first.x;
    const dY = last.y - first.y;

    // 水平滑动
    if (Math.abs(dX) > Math.abs(dY)) {
      // 保留X方向变化明显的键
      const filteredKeys = path.keys.filter((_, i) => {
        if (i >= path.points.length) return false;
        const p = path.points[i];
        return Math.abs(p.x - first.x) > this.SHAKE_THRESHOLD;
      });
      return { ...path, keys: filteredKeys.length > 0 ? filteredKeys : path.keys };
    }

    // 垂直滑动
    return path;
  }
}

// =============== 模块导出 ===============

export default {
  SwipeInputEngine,
  KeyPosition,
  EdgeCaseHandler,
  EdgeCaseType
};