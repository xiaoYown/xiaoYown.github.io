# 使用 Playwright 收集性能指标

## 简介

编写操作流程性能指标采集脚本, 采集脚本 + 操作流程文件 完成操作流程性能指标采集.

采集前必须保证 performance monitor 打开.

## 开发项

- 基于 Playwright 编写采集脚本
- 编写操作流程文件(多个)

## 采集脚本功能

- 运行脚本 + 操作流程文件, 完成操作流程性能指标采集
- 封装操作集: 页面元素交互事件, 清空性能数据缓存触发 devtools performance collect garbage, 收集性能(CPU usage, JS heap size, DOM nodes, JS events listeners)

操作集:

| 触发                         | 选择器 | 目标     | 描述                                                              |
| ---------------------------- | ------ | -------- | ----------------------------------------------------------------- |
| dom:click                    | #btn   | 点击按钮 | 点击按钮                                                          |
| devtools:collect-garbage     | -      | -        | 清空性能数据缓存触发 devtools performance collect garbage         |
| devtools:collect-performance | -      | -        | 收集性能(CPU usage, JS heap size, DOM nodes, JS events listeners) |

## 操作流程文件

> 存放路径: ./flows

- 操作流程文件格式: JSON
- 指定操作流程, 完成操作流程性能指标采集

操作流程文件格式:

```ts
{
  // 操作流程名称
  "name": string;
  // 操作流程轮询间隔(秒)
  "polling": number;
  // 操作流程步骤
  "steps": {
    "trigger": 'dom:click' | 'devtools:collect-garbage' | 'devtools:collect-performance';
    "selector": string;
  }[];  
}
```

示例:

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

## 生成报告

> 存放路径:./reports

- 报告格式: HTML
- 报告内容: 性能指标数据表格 + 折线图 + 总结 