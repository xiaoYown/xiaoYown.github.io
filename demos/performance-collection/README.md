# 使用 Playwright 收集性能指标

## 简介

这是一个基于 Playwright 的自动化性能指标采集工具。通过编写操作流程性能指标采集脚本，结合操作流程文件，可以自动完成页面操作并采集相关性能指标数据。该工具特别适合用于页面性能监控、性能优化前后对比以及性能回归测试等场景。

## 前置条件

- Node.js 环境 (推荐 v16+)
- 采集前必须保证 Chrome DevTools 的 Performance Monitor 面板打开
- 确保目标页面可访问且状态正常

## 开发项

- 基于 Playwright 编写采集脚本
- 编写操作流程文件(支持多个流程文件)
- 生成性能报告

## 采集脚本功能

### 主要功能

- 运行脚本 + 操作流程文件，自动完成操作流程性能指标采集
- 封装常用操作集：页面元素交互事件、性能数据采集等
- 支持定时采集和条件触发采集
- 生成可视化性能报告

### 性能指标采集

采集以下关键性能指标：

- CPU Usage：CPU 使用率
- JS Heap Size：JavaScript 堆内存大小
- DOM Nodes：DOM 节点数量
- JS Event Listeners：JavaScript 事件监听器数量

### 操作集

| 触发                         | 选择器 | 目标     | 描述                                                              |
| ---------------------------- | ------ | -------- | ----------------------------------------------------------------- |
| dom:click                    | #btn   | 点击按钮 | 点击指定选择器的元素                                               |
| devtools:collect-garbage     | -      | -        | 清空性能数据缓存，触发 DevTools Performance 垃圾回收               |
| devtools:collect-performance | -      | -        | 采集性能指标数据                                                   |

## 操作流程文件

### 存放位置

操作流程文件统一存放在 `./flows` 目录下

### 文件格式

- 文件格式：JSON
- 文件命名：建议使用有意义的名称，如 `login-flow.json`、`main-process.json` 等

### 配置说明

```ts
{
  // 操作流程名称
  "name": string;
  // 操作流程轮询间隔(秒)
  "polling": number;
  // 操作流程步骤
  "steps": {
    // 触发动作类型
    "trigger": 'dom:click' | 'devtools:collect-garbage' | 'devtools:collect-performance';
    // 元素选择器（仅 dom 类操作需要）
    "selector": string;
  }[];  
}
```

### 示例

```json
{
  "name": "test",
  "polling": 2,
  "steps": [
    {
      "trigger": "devtools:collect-garbage"
    },
    {
      "trigger": "devtools:collect-performance"
    },
    {
      "trigger": "dom:click",
      "selector": "#btn"
    },
    {
      "trigger": "devtools:collect-performance"
    },
    {
      "trigger": "devtools:collect-performance"
    },
    {
      "trigger": "dom:click",
      "selector": "#canvas"
    },
    {
      "trigger": "devtools:collect-performance"
    },
    {
      "trigger": "devtools:collect-performance"
    }
  ]
}
```

## 性能报告

### 存放位置

生成的报告文件存放在 `./reports` 目录下

### 报告格式

- 格式：HTML
- 文件命名：`{flow-name}-{timestamp}.html`

### 报告内容

1. 性能指标数据表格
   - 采集时间
   - CPU 使用率
   - 内存使用情况
   - DOM 节点数量
   - 事件监听器数量

2. 性能指标趋势图
   - 折线图展示各项指标随时间变化趋势
   - 支持缩放和时间段选择
   - 可单独显示/隐藏某项指标

3. 性能分析总结
   - 性能指标峰值记录
   - 异常数据标记
   - 性能瓶颈分析
   - 优化建议

## 使用说明

1. 安装依赖
```bash
pnpm install
```

2. 编写或选择操作流程文件

3. 运行采集脚本
```bash
pnpm run collect <flow-file-path>
```

4. 查看生成的性能报告