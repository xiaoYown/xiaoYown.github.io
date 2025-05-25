import { writeFile, readFile } from 'fs/promises';
import { join } from 'path';
import { PerformanceMetrics } from './types';

/**
 * 性能报告生成器
 * 负责生成性能测试报告
 */
export class ReportGenerator {
  private readonly metricsData: PerformanceMetrics[][];
  private readonly templatePath: string;

  constructor(metricsData: PerformanceMetrics[][]) {
    this.metricsData = metricsData;
    this.templatePath = join(__dirname, 'templates/report.html');
  }

  /**
   * 加载报告模板
   */
  private async loadTemplate(): Promise<string> {
    try {
      return await readFile(this.templatePath, 'utf-8');
    } catch (error) {
      console.error('加载报告模板失败:', error);
      throw new Error('无法加载报告模板文件');
    }
  }

  /**
   * 生成报告文件名
   */
  private generateReportFilename(): string {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    return `performance-report-${timestamp}.html`;
  }

  /**
   * 替换模板变量
   * @param template 模板内容
   */
  private replaceTemplateVariables(template: string): string {
    return template
      .replace('{{GENERATE_TIME}}', new Date().toLocaleString())
      .replace('{{METRICS_DATA}}', JSON.stringify(this.metricsData));
  }

  /**
   * 生成性能报告
   * @returns 报告文件路径
   */
  async generateReport(): Promise<string> {
    try {
      // 加载模板
      const template = await this.loadTemplate();
      
      // 替换变量
      const html = this.replaceTemplateVariables(template);

      // 生成报告文件
      const reportFilename = this.generateReportFilename();
      const reportPath = join(__dirname, '../reports', reportFilename);
      
      await writeFile(reportPath, html);
      console.log(`报告生成成功: ${reportPath}`);
      
      return reportPath;
    } catch (error) {
      console.error('生成报告失败:', error);
      throw new Error('报告生成失败');
    }
  }
}