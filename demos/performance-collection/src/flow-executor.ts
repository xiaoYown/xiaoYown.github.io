import { Browser, Page, chromium } from 'playwright';
import { Flow, FlowStep, PerformanceMetrics } from './types';
import { PerformanceCollector } from './performance-collector';

/**
 * 测试流程执行器
 * 负责执行测试流程并收集性能指标
 */
export class FlowExecutor {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private metrics: PerformanceMetrics[][] = [];
  private flowName: string = '';
  private currentRound: number = 0;

  /**
   * 初始化浏览器环境
   */
  async init() {
    console.log('初始化浏览器...');
    this.browser = await chromium.launch({
      headless: false,
      channel: 'chrome',
      executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      args: ['--auto-open-devtools-for-tabs']
    });
    this.page = await this.browser.newPage();
    console.log('浏览器初始化完成');
  }

  /**
   * 加载测试页面
   * @param url 页面URL
   */
  async loadPage(url: string) {
    if (!this.page) throw new Error('页面未初始化');
    console.log(`加载页面: ${url}`);
    await this.page.goto(url);
    console.log('页面加载完成');
  }

  /**
   * 执行单个测试步骤
   * @param step 测试步骤
   */
  private async executeStep(step: FlowStep) {
    if (!this.page) throw new Error('页面未初始化');

    console.log(`执行步骤: ${step.trigger}${step.selector ? ` (选择器: ${step.selector})` : ''}${step.duration ? ` (等待: ${step.duration}ms)` : ''}`);

    try {
      switch (step.trigger) {
        case 'dom:click':
          if (!step.selector) throw new Error('点击操作需要选择器');
          await this.page.click(step.selector);
          break;

        case 'devtools:collect-garbage':
          await this.page.evaluate(() => {
            // @ts-ignore
            window.gc && window.gc();
          });
          // 使用 CDP 的垃圾回收机制
          const gcClient = await this.page.context().newCDPSession(this.page);
          await gcClient.send('HeapProfiler.enable');
          await gcClient.send('HeapProfiler.collectGarbage');
          await gcClient.send('HeapProfiler.disable');
          break;

        case 'devtools:collect-performance':
          const client = await this.page.context().newCDPSession(this.page);
          await client.send('Runtime.enable');
          await client.send('Debugger.enable');

          // 获取性能指标
          const metrics = await PerformanceCollector.collect(
            client,
            this.currentRound,
            this.metrics[this.currentRound - 1].length + 1
          );
          
          // 记录并打印指标
          this.metrics[this.currentRound - 1].push(metrics);
          PerformanceCollector.logMetrics(metrics);
          break;

        case 'flow:wait':
          if (!step.duration) throw new Error('等待操作需要指定时间');
          console.log(`等待 ${step.duration}ms...`);
          await this.page.waitForTimeout(step.duration);
          break;
      }
    } catch (error) {
      console.error(`步骤执行失败: ${error}`);
      throw error;
    }
  }

  /**
   * 执行测试流程
   * @param flow 测试流程配置
   */
  async executeFlow(flow: Flow) {
    this.flowName = flow.name;
    this.metrics = [];
    console.log(`开始执行流程: ${flow.name}`);
    
    // 计算实际轮次数
    const rounds = Math.max(1, flow.polling || 1);
    console.log(`将执行 ${rounds} 轮测试`);
    
    // 执行多轮测试
    for (let round = 1; round <= rounds; round++) {
      this.currentRound = round;
      this.metrics.push([]);
      
      console.log(`\n开始第 ${round} 轮测试`);
      console.log('----------------------------------------');
      
      // 执行所有步骤
      for (const step of flow.steps) {
        await this.executeStep(step);
      }
      
      // 显示当前轮次的统计信息
      this.logRoundSummary(round);
    }

    this.logTestSummary();
  }

  /**
   * 打印轮次统计信息
   * @param round 轮次
   */
  private logRoundSummary(round: number) {
    const roundMetrics = this.metrics[round - 1];
    if (roundMetrics.length > 0) {
      const firstMetrics = roundMetrics[0];
      const lastMetrics = roundMetrics[roundMetrics.length - 1];
      
      console.log(`\n第 ${round} 轮测试完成`);
      console.log(`采集次数: ${roundMetrics.length}`);
      console.log('指标变化:');
      console.log(`DOM 节点数: ${firstMetrics.domNodes} -> ${lastMetrics.domNodes}`);
      console.log(`JS 堆内存: ${(firstMetrics.jsHeapSize / (1024 * 1024)).toFixed(2)}MB -> ${(lastMetrics.jsHeapSize / (1024 * 1024)).toFixed(2)}MB`);
      console.log(`事件监听器数量: ${firstMetrics.jsEventListeners} -> ${lastMetrics.jsEventListeners}`);
      console.log('----------------------------------------');
    }
  }

  /**
   * 打印测试总结
   */
  private logTestSummary() {
    console.log('\n性能测试总结:');
    console.log(`完成轮次: ${this.metrics.length}`);
    console.log(`每轮采集次数: ${this.metrics.map((m, i) => `第${i + 1}轮: ${m.length}次`).join(', ')}`);
    console.log('----------------------------------------');
  }

  /**
   * 获取收集的性能指标数据
   */
  getMetrics(): PerformanceMetrics[][] {
    return this.metrics;
  }

  /**
   * 关闭浏览器
   */
  async close() {
    console.log('关闭浏览器...');
    await this.browser?.close();
    console.log('浏览器已关闭');
  }
} 