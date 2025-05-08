import { writeFile } from 'fs/promises';
import { join } from 'path';

interface PerformanceMetrics {
  timestamp: number;
  cpuUsage: number;
  jsHeapSize: number;
  domNodes: number;
  jsEventListeners: number;
}

export class ReportGenerator {
  constructor(private metrics: PerformanceMetrics[]) {}

  private generateChartData() {
    return {
      labels: this.metrics.map(m => new Date(m.timestamp).toLocaleTimeString()),
      datasets: [
        {
          label: 'CPU Usage',
          data: this.metrics.map(m => m.cpuUsage)
        },
        {
          label: 'JS Heap Size (MB)',
          data: this.metrics.map(m => m.jsHeapSize / (1024 * 1024))
        },
        {
          label: 'DOM Nodes',
          data: this.metrics.map(m => m.domNodes)
        },
        {
          label: 'JS Event Listeners',
          data: this.metrics.map(m => m.jsEventListeners)
        }
      ]
    };
  }

  private generateTableHTML() {
    return `
      <table class="metrics-table">
        <thead>
          <tr>
            <th>Time</th>
            <th>CPU Usage</th>
            <th>JS Heap Size (MB)</th>
            <th>DOM Nodes</th>
            <th>Event Listeners</th>
          </tr>
        </thead>
        <tbody>
          ${this.metrics.map(m => `
            <tr>
              <td>${new Date(m.timestamp).toLocaleTimeString()}</td>
              <td>${m.cpuUsage.toFixed(2)}</td>
              <td>${(m.jsHeapSize / (1024 * 1024)).toFixed(2)}</td>
              <td>${m.domNodes}</td>
              <td>${m.jsEventListeners}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    `;
  }

  private generateSummary() {
    const lastMetric = this.metrics[this.metrics.length - 1];
    const firstMetric = this.metrics[0];
    
    const changes = {
      cpuUsage: firstMetric.cpuUsage === 0 ? 0 : ((lastMetric.cpuUsage - firstMetric.cpuUsage) / firstMetric.cpuUsage * 100).toFixed(2),
      jsHeapSize: firstMetric.jsHeapSize === 0 ? 0 : ((lastMetric.jsHeapSize - firstMetric.jsHeapSize) / firstMetric.jsHeapSize * 100).toFixed(2),
      domNodes: firstMetric.domNodes === 0 ? 0 : ((lastMetric.domNodes - firstMetric.domNodes) / firstMetric.domNodes * 100).toFixed(2),
      jsEventListeners: firstMetric.jsEventListeners === 0 ? 0 : ((lastMetric.jsEventListeners - firstMetric.jsEventListeners) / firstMetric.jsEventListeners * 100).toFixed(2)
    };

    return `
      <div class="summary">
        <h2>性能变化总结</h2>
        <ul>
          <li>CPU 使用率变化: ${changes.cpuUsage}%</li>
          <li>JS 堆内存变化: ${changes.jsHeapSize}%</li>
          <li>DOM 节点数变化: ${changes.domNodes}%</li>
          <li>事件监听器数量变化: ${changes.jsEventListeners}%</li>
        </ul>
      </div>
    `;
  }

  async generateReport(): Promise<string> {
    try {
      const chartData = this.generateChartData();
      const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>性能指标报告</title>
          <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
          <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .metrics-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
            .metrics-table th, .metrics-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            .metrics-table th { background-color: #f5f5f5; }
            .chart-container { margin: 20px 0; height: 400px; }
            .summary { margin: 20px 0; padding: 20px; background-color: #f9f9f9; border-radius: 5px; }
          </style>
        </head>
        <body>
          <h1>性能指标报告</h1>
          
          <div class="chart-container">
            <canvas id="metricsChart"></canvas>
          </div>

          ${this.generateSummary()}
          ${this.generateTableHTML()}

          <script>
            const ctx = document.getElementById('metricsChart').getContext('2d');
            new Chart(ctx, {
              type: 'line',
              data: ${JSON.stringify(chartData)},
              options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                  y: { beginAtZero: true }
                }
              }
            });
          </script>
        </body>
      </html>
    `;

      const reportPath = join(__dirname, '../reports/performance-report.html');
      await writeFile(reportPath, html);
      return reportPath;
    } catch (error) {
      console.error('生成报告失败:', error);
      throw error;
    }
  }
}