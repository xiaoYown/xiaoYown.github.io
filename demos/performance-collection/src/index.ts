import { readFile } from 'fs/promises';
import { resolve } from 'path';
import { exec } from 'child_process';
import type { Flow } from './types';
import { FlowExecutor } from './flow-executor';
import { ReportGenerator } from './report-generator';

/**
 * 性能测试工具
 * 用于执行性能测试流程并生成报告
 */
export class PerformanceTestTool {
  private executor: FlowExecutor;

  constructor() {
    this.executor = new FlowExecutor();
  }

  /**
   * 执行性能测试
   * @param flow 测试流程配置
   */
  async run(flow: Flow): Promise<string> {
    try {
      // 初始化执行器
      await this.executor.init();

      // 加载测试页面
      await this.executor.loadPage(flow.url);

      // 执行测试流程
      await this.executor.executeFlow(flow);

      // 获取性能指标数据
      const metricsData = this.executor.getMetrics();

      // 生成报告
      const reportGenerator = new ReportGenerator(metricsData);
      const reportPath = await reportGenerator.generateReport();

      // 关闭浏览器
      await this.executor.close();

      // 打开报告
      exec(`open "${reportPath}"`, (error) => {
        if (error) {
          console.error('打开报告失败:', error);
        } else {
          console.log('报告已在浏览器中打开');
        }
      });

      return reportPath;
    } catch (error) {
      console.error('性能测试执行失败:', error);
      await this.executor.close();
      throw error;
    }
  }
}

async function main() {
  try {
    // 获取配置文件路径
    const flowPath = resolve(process.argv[2]);
    if (!flowPath) {
      throw new Error('请提供流程配置文件路径');
    }

    // 读取配置文件
    const flowContent = await readFile(flowPath, 'utf-8');
    const flow: Flow = JSON.parse(flowContent);

    // 执行测试
    const tool = new PerformanceTestTool();
    const reportPath = await tool.run(flow);
    console.log('测试完成，报告路径:', reportPath);
  } catch (error) {
    console.error('测试失败:', error);
    process.exit(1);
  }
}

// 仅在直接运行时执行
if (require.main === module) {
  main();
}