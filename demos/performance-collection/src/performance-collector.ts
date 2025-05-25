import { Browser, Page } from 'playwright';
import { PerformanceMetrics } from './types';

/**
 * 性能指标收集器
 * 负责通过 Chrome DevTools Protocol 收集性能指标
 */
export class PerformanceCollector {
  /**
   * 获取性能指标
   * @param client CDP客户端
   * @param round 当前轮次
   * @param step 当前步骤
   */
  static async collect(client: any, round: number, step: number): Promise<PerformanceMetrics> {
    // 启用性能指标收集
    await client.send('Performance.enable');
    await client.send('HeapProfiler.enable');

    // 获取性能指标
    const { metrics } = await client.send('Performance.getMetrics');
    
    // 查找相关指标
    const findMetric = (name: string) => {
      const metric = metrics.find((m: { name: string; value: number }) => m.name === name);
      return metric ? metric.value : 0;
    };

    // 获取事件监听器数量
    const { result } = await client.send('Runtime.evaluate', {
      expression: `
        (() => {
          let count = 0;
          const elements = document.getElementsByTagName('*');
          
          // 统计通过 addEventListener 添加的事件
          for (const element of elements) {
            const events = getEventListeners(element);
            count += Object.keys(events).reduce((sum, type) => sum + events[type].length, 0);
          }
          
          // 统计 DOM0 级事件（on* 属性）
          for (const element of elements) {
            count += Object.getOwnPropertyNames(element)
              .filter(prop => prop.startsWith('on') && element[prop])
              .length;
          }
          
          return count;
        })()
      `,
      includeCommandLineAPI: true
    });

    // 获取相关指标
    const domNodes = findMetric('Nodes');
    const jsHeapSize = findMetric('JSHeapUsedSize');
    const scriptDuration = findMetric('ScriptDuration');

    // 禁用性能指标收集
    await client.send('HeapProfiler.disable');
    await client.send('Performance.disable');

    return {
      timestamp: Date.now(),
      cpuUsage: scriptDuration * 1000, // 转换为毫秒
      jsHeapSize: jsHeapSize,
      domNodes: domNodes,
      jsEventListeners: result.value || 0,
      round,
      step
    };
  }

  /**
   * 打印性能指标
   * @param metrics 性能指标数据
   */
  static logMetrics(metrics: PerformanceMetrics): void {
    console.log(`\n第 ${metrics.round} 轮 - 第 ${metrics.step} 次采集:`);
    console.log(`时间: ${new Date(metrics.timestamp).toLocaleTimeString()}`);
    console.log(`DOM 节点数: ${metrics.domNodes}`);
    console.log(`JS 堆内存: ${(metrics.jsHeapSize / (1024 * 1024)).toFixed(2)} MB`);
    console.log(`事件监听器数量: ${metrics.jsEventListeners}`);
    console.log(`CPU 使用时间: ${metrics.cpuUsage.toFixed(2)} ms`);
    console.log('----------------------------------------');
  }
} 