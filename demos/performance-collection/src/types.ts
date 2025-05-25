/**
 * 性能指标数据接口
 */
export interface PerformanceMetrics {
  /** 采集时间戳 */
  timestamp: number;
  /** CPU使用时间(ms) */
  cpuUsage: number;
  /** JS堆内存大小(bytes) */
  jsHeapSize: number;
  /** DOM节点数量 */
  domNodes: number;
  /** 事件监听器数量 */
  jsEventListeners: number;
  /** 所属轮次 */
  round: number;
  /** 采集步骤 */
  step: number;
}

/**
 * 测试流程步骤类型
 */
export interface FlowStep {
  /** 触发动作类型 */
  trigger: 'dom:click' | 'devtools:collect-garbage' | 'devtools:collect-performance' | 'flow:wait';
  /** DOM选择器 */
  selector?: string;
  /** 等待时间(毫秒) */
  duration?: number;
}

/**
 * 测试流程配置接口
 */
export interface Flow {
  /** 流程名称 */
  name: string;
  /** 轮询间隔(秒) */
  polling: number;
  /** 测试页面URL */
  url: string;
  /** 测试步骤列表 */
  steps: FlowStep[];
} 