import { chromium, Browser, Page } from 'playwright';
import { readFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { join } from 'path';
import { exec } from 'child_process';
import { ReportGenerator } from './report-generator';

interface FlowStep {
  trigger: 'dom:click' | 'devtools:collect-garbage' | 'devtools:collect-performance';
  selector?: string;
}

interface Flow {
  name: string;
  polling: number;
  steps: FlowStep[];
}

interface PerformanceMetrics {
  timestamp: number;
  cpuUsage: number;
  jsHeapSize: number;
  domNodes: number;
  jsEventListeners: number;
}

class PerformanceCollector {
  private browser: Browser | null = null;
  private page: Page | null = null;
  private metrics: PerformanceMetrics[] = [];
  private flowName: string = '';

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

  async loadPage(url: string) {
    if (!this.page) throw new Error('页面未初始化');
    console.log(`加载页面: ${url}`);
    await this.page.goto(url);
    console.log('页面加载完成');
  }

  async executeStep(step: FlowStep) {
    if (!this.page) throw new Error('页面未初始化');

    console.log(`执行步骤: ${step.trigger}${step.selector ? ` (选择器: ${step.selector})` : ''}`);

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
          break;

        case 'devtools:collect-performance':
          // 使用 CDP 会话获取事件监听器数量
          const client = await this.page.context().newCDPSession(this.page);
          await client.send('Runtime.enable');
          await client.send('Debugger.enable');
          await client.send('DOM.enable');
          
          // 获取文档对象的 objectId
          const { result: { objectId } } = await client.send('Runtime.evaluate', { 
            expression: 'document',
            returnByValue: false
          });
          
          if (!objectId) {
            throw new Error('无法获取文档对象 ID');
          }
          
          // 获取事件监听器数量
          const { listeners } = await client.send('DOMDebugger.getEventListeners', { objectId });
          
          // 收集性能指标
          const metrics = await this.page.evaluate(() => {
            const performance = window.performance as any;
            const memory = performance.memory || {};
            const elements = document.getElementsByTagName('*');
            
            return {
              timestamp: Date.now(),
              cpuUsage: performance.now(),
              jsHeapSize: memory.usedJSHeapSize || 0,
              domNodes: elements.length,
              jsEventListeners: 0 // 将在外部设置
            };
          });
          
          metrics.jsEventListeners = listeners.length;
          this.metrics.push(metrics);
          console.log('性能指标已收集:', metrics);
          break;
      }
    } catch (error) {
      console.error(`步骤执行失败: ${error}`);
      throw error;
    }
  }

  async executeFlow(flow: Flow) {
    this.flowName = flow.name;
    console.log(`开始执行流程: ${flow.name}`);
    
    for (const step of flow.steps) {
      await this.executeStep(step);
      if (flow.polling > 0) {
        console.log(`等待 ${flow.polling} 秒...`);
        await this.page?.waitForTimeout(flow.polling * 1000);
      }
    }

    console.log('流程执行完成');
  }

  async generateReport() {
    if (this.metrics.length === 0) {
      console.warn('没有收集到性能指标数据');
      return;
    }

    const reportsDir = join(__dirname, '../reports');
    if (!existsSync(reportsDir)) {
      await mkdir(reportsDir, { recursive: true });
    }

    const generator = new ReportGenerator(this.metrics);
    const reportPath = await generator.generateReport();
    console.log(`报告已生成: ${reportPath}`);
    
    // 打开报告
    exec(`open "${reportPath}"`, (error) => {
      if (error) {
        console.error('打开报告失败:', error);
      } else {
        console.log('报告已在浏览器中打开');
      }
    });
  }

  async close() {
    console.log('关闭浏览器...');
    await this.browser?.close();
    console.log('浏览器已关闭');
  }
}

async function main() {
  const collector = new PerformanceCollector();

  try {
    const flowPath = join(__dirname, '../flows/test.json');
    if (!existsSync(flowPath)) {
      throw new Error(`流程文件不存在: ${flowPath}`);
    }

    const flowContent = await readFile(flowPath, 'utf-8');
    const flow: Flow = JSON.parse(flowContent);
    
    await collector.init();
    await collector.loadPage('http://localhost:3000'); // 替换为目标URL
    await collector.executeFlow(flow);
    await collector.generateReport();
  } catch (error) {
    console.error('程序执行错误:', error);
    process.exit(1);
  } finally {
    await collector.close();
  }
}

main();