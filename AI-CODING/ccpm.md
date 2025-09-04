[来源](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM)

___

在 AI 编程快速崛起的今天，越来越多的开发者和团队开始尝试将 **Claude Code**、ChatGPT Code Interpreter 等工具引入到日常开发工作流中。但随之而来的一个现实问题是：**AI 辅助开发虽然能提升速度，但团队协作、上下文管理、任务拆分和代码质量保障，依旧是痛点。**

> 🚀本篇笔记所对应的视频：
> 
> -   [👉👉👉 通过哔哩哔哩观看](https://www.bilibili.com/video/BV16EaKzjEwb/)
> -   [👉👉👉 通过YouTube观看](https://youtu.be/5hmeTZdRt6Y)
> -   [👉👉👉 Subagents视频](https://youtu.be/GjlkRcNNONo)
> -   [👉👉👉 Gemini CLI视频](https://youtu.be/v41xKxZmygU)
> -   [👉👉👉 Context Engineering视频](https://youtu.be/oEZ7aN7jOEI)
> -   [👉👉👉 SuperClaude视频](https://youtu.be/bMO13RNjvBk)
> -   [👉👉👉 Claudia视频](https://youtu.be/WIwW7V56wxE)
> -   [👉👉👉 Task Master视频](https://youtu.be/6dhOUJ_vnIY)
> -   [👉👉👉 Zen MCP编程视频](https://youtu.be/2WgICfNzgZY)
> -   [👉👉👉 Augment编程视频](https://youtu.be/DbM3QZy5I6E)
> -   [👉👉👉 Serena MCP视频](https://youtu.be/DZ-gLebVnmg)
> -   [👉👉👉 我的开源项目](https://github.com/win4r/AISuperDomain)
> -   [👉👉👉 请我喝咖啡](https://ko-fi.com/aila)
> -   👉👉👉 我的微信：stoeng
> -   👉👉👉 承接大模型微调、RAG、AI智能体、AI相关应用开发等项目。
> 
> 🔥AI智能体相关视频
> 
> -   [AI智能体视频 1](https://youtu.be/vYm0brFoMwA)
> -   [AI智能体视频 2](https://youtu.be/szTXELuaJos)
> -   [AI智能体视频 3](https://youtu.be/szTXELuaJos)
> -   [AI智能体视频 4](https://youtu.be/RxR3x_Uyq4c)
> -   [AI智能体视频 5](https://youtu.be/IrTEDPnEVvU)
> -   [AI智能体视频 6](https://youtu.be/q_IdxUGZsow)

如果只是个人写一个小脚本，AI 已经很好用了。但当一个团队想要交付一个功能完善、可追溯、可协作的大型项目时，就会遇到如下问题：

-   **上下文容易丢失**：AI 一次只能处理有限上下文，复杂项目需要反复补充说明。
-   **任务容易阻塞**：传统开发往往是串行执行，一个环节没完成，后续都得等。
-   **代码质量不稳定**：AI 生成的代码有时过于随意，缺乏规范和可追溯性。
-   **协作成本高**：AI 和人类开发者之间如何切换和同步进展？

这正是 **CCPM（Claude Code Project Management）** 想要解决的问题。

___

## 什么是 CCPM？[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#%E4%BB%80%E4%B9%88%E6%98%AF-ccpm "Permalink")

CCPM，全称 **Claude Code Project Management**，是一个开源的项目管理框架，专为 **Claude Code 用户和 AI 辅助开发团队**设计。它通过 GitHub Issues 与 Git worktrees 的组合，将传统的需求文档、技术设计、任务拆分、代码生成和交付过程，完整串联成一条可追溯、可协作、可自动化的开发流水线。

一句话总结：

👉 CCPM 可以把 **PRD（产品需求文档） → Epic（技术方案） → Issues（任务拆分） → Code（生产代码）** 全流程自动化执行，并确保 **上下文不丢失、过程可追溯、结果高质量**。

___

## CCPM 的核心优势[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#ccpm-%E7%9A%84%E6%A0%B8%E5%BF%83%E4%BC%98%E5%8A%BF "Permalink")

相比传统的开发模式，CCPM 带来的优势非常明显：

### 1\. 上下文永不丢失[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#1-%E4%B8%8A%E4%B8%8B%E6%96%87%E6%B0%B8%E4%B8%8D%E4%B8%A2%E5%A4%B1 "Permalink")

CCPM 会在本地为每个任务维护独立上下文，存放在 `.claude/` 文件夹中。无论是 AI Agent 还是人类开发者，都能随时调取历史记录，不需要来回补充背景信息。

这极大地减少了“反复解释”的时间浪费，用户反馈显示 **上下文切换时间可减少 89%**。

### 2\. 并行开发，效率翻倍[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#2-%E5%B9%B6%E8%A1%8C%E5%BC%80%E5%8F%91%E6%95%88%E7%8E%87%E7%BF%BB%E5%80%8D "Permalink")

在 CCPM 中，大任务会被拆分成多个独立任务（issues），标记为 `parallel: true` 后，可以交给多个 AI Agent 或团队成员同时进行。

这意味着你可以让 **5-8 个任务并行执行**，而不是傻等前一个任务完成。最终的交付速度，通常比传统串行开发快 **2-3 倍**。

### 3\. 杜绝「Vibe Coding」[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#3-%E6%9D%9C%E7%BB%9Dvibe-coding "Permalink")

所谓 Vibe Coding，就是“凭感觉写代码”。这在 AI 生成代码的场景下尤其常见，容易导致 bug 和返工。

CCPM 强调 **每一行代码必须可追溯到 PRD → Epic → Issue 的源头**，从根本上保证了代码的合理性和质量。据用户反馈，bug 率降低了 **75%**。

### 4\. 无缝协作，天然支持分布式团队[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#4-%E6%97%A0%E7%BC%9D%E5%8D%8F%E4%BD%9C%E5%A4%A9%E7%84%B6%E6%94%AF%E6%8C%81%E5%88%86%E5%B8%83%E5%BC%8F%E5%9B%A2%E9%98%9F "Permalink")

所有任务和进展会自动同步到 **GitHub Issues**，这成为团队的“单一真相中心”。

人类和 AI 可以随时切换执行任务，不会出现“我做了一半，AI 接不上”或者“AI 写的代码没人能看懂”的情况，非常适合远程和分布式团队。

### 5\. 开源、可扩展、隐私友好[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#5-%E5%BC%80%E6%BA%90%E5%8F%AF%E6%89%A9%E5%B1%95%E9%9A%90%E7%A7%81%E5%8F%8B%E5%A5%BD "Permalink")

CCPM 完全开源（MIT 协议），支持本地运行。你可以将它与自己的 CI/CD、文档生成器，甚至其他 AI Agent 通信协议（ACP）结合，实现高度定制化。

___

## CCPM 的使用场景[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#ccpm-%E7%9A%84%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF "Permalink")

那么，CCPM 适合用在什么样的团队和项目里呢？

### ✅ 1. 从 0 到 1 的功能开发[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#-1-%E4%BB%8E-0-%E5%88%B0-1-%E7%9A%84%E5%8A%9F%E8%83%BD%E5%BC%80%E5%8F%91 "Permalink")

假设你要开发一个全新的功能（比如一个 **Todo List 应用**），只需要：

1.  用 `/pm:prd-new todo-list` 生成产品需求文档
2.  用 `/pm:prd-parse todo-list` 转成技术方案
3.  用 `/pm:epic-decompose todo-list` 拆解为任务
4.  启动 AI Agents 并行执行
5.  `/pm:epic-merge todo-list` 一键合并代码到主分支

最终，你会得到一个 **可直接上线的完整应用**，包含 HTML、CSS、JS、测试和文档。

### ✅ 2. 复杂项目的多团队协作[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#-2-%E5%A4%8D%E6%9D%82%E9%A1%B9%E7%9B%AE%E7%9A%84%E5%A4%9A%E5%9B%A2%E9%98%9F%E5%8D%8F%E4%BD%9C "Permalink")

在大型项目中，不同团队负责不同模块，AI 和人类开发者需要频繁切换。CCPM 的上下文管理和 GitHub 集成，保证了任务不会丢失、信息不会断层。

### ✅ 3. 想要提升研发效率的 AI 驱动团队[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#-3-%E6%83%B3%E8%A6%81%E6%8F%90%E5%8D%87%E7%A0%94%E5%8F%91%E6%95%88%E7%8E%87%E7%9A%84-ai-%E9%A9%B1%E5%8A%A8%E5%9B%A2%E9%98%9F "Permalink")

如果你正在尝试 **AI 结对编程（Pair Programming）** 或 **AI 辅助 Scrum 开发**，CCPM 可以作为核心工作流框架，帮你把碎片化的 AI 交互变成系统化的工程实践。

___

## 一个案例：Todo List 开发[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#%E4%B8%80%E4%B8%AA%E6%A1%88%E4%BE%8Btodo-list-%E5%BC%80%E5%8F%91 "Permalink")

在官方示例中，一个 **Todo List 应用** 通过 CCPM 被完整开发：

-   **HTML 架构**：符合语义化、可访问性标准
-   **CSS 系统**：响应式布局，支持移动端
-   **核心 JS 功能**：CRUD + LocalStorage 持久化
-   **用户体验优化**：键盘快捷键 + 动画效果
-   **跨浏览器测试**：通过率 93.6%，WCAG 2.1 AA 合规

整个过程 **3.5 小时完成**，最终产出 **7500+ 行代码** 和完整测试文档，达到可直接生产部署的标准。

___

## 总结[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#%E6%80%BB%E7%BB%93 "Permalink")

在 AI 编程逐渐成为主流的今天，CCPM 提供了一种全新的思路：

它不是替代开发者，而是通过 **上下文管理 + 并行执行 + 可追溯性 + 自动化协作**，让人类与 AI 的合作更加高效、可靠、专业。

如果你是：

-   想要快速交付产品的创业团队
-   想探索 AI 辅助敏捷开发的新方式
-   或者是分布式远程团队，想解决协作和上下文丢失的问题

👉 那么 CCPM 将会是你非常值得尝试的一款工具。

项目地址：

[https://github.com/automazeio/ccpm](https://github.com/automazeio/ccpm)

未来，随着 AI 辅助开发工具不断进化，像 CCPM 这样连接 **需求 → 计划 → 执行 → 测试 → 部署** 的工作流系统，或许会成为开发团队的标配。

___

### ⚡️安装方式[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#%EF%B8%8F%E5%AE%89%E8%A3%85%E6%96%B9%E5%BC%8F "Permalink")

**✅Unix/Linux/macOS (direct commands)**

```bash
git clone https://github.com/automazeio/ccpm.git . && rm -rf .git
```

**✅Windows (cmd)**

```bash
git clone https://github.com/automazeio/ccpm.git . && rmdir /s /q .git
```

**✅Windows (PowerShell)**

```bash
git clone https://github.com/automazeio/ccpm.git .; Remove-Item -Recurse -Force .git
```

___

### ⏺ **_📚 Claude Code PM 帮助文档（中文版）_**[Permalink](https://www.aivi.fyi/aiagents/introduce-Claude-Code-PM#--claude-code-pm-%E5%B8%AE%E5%8A%A9%E6%96%87%E6%A1%A3%E4%B8%AD%E6%96%87%E7%89%88 "Permalink")

🎯 **快速开始工作流**

1.  `/pm:prd-new` —— 创建一个新的 PRD（产品需求文档）
2.  `/pm:prd-parse` —— 将 PRD 转换为 Epic（实现方案）
3.  `/pm:epic-decompose` —— 将 Epic 拆分为任务
4.  `/pm:epic-sync` —— 同步到 GitHub
5.  `/pm:epic-start` —— 启动并行执行

___

📄 **PRD 命令**

-   `/pm:prd-new` —— 新建一个产品需求文档（头脑风暴入口）
-   `/pm:prd-parse` —— 将 PRD 转换为实现方案（Epic）
-   `/pm:prd-list` —— 列出所有 PRD
-   `/pm:prd-edit` —— 编辑现有 PRD
-   `/pm:prd-status` —— 查看 PRD 的实现进度

___

📚 **Epic 命令**

-   `/pm:epic-decompose` —— 将 Epic 拆分为任务文件
-   `/pm:epic-sync` —— 同步 Epic 和任务到 GitHub
-   `/pm:epic-oneshot` —— 一键完成拆分和同步
-   `/pm:epic-list` —— 列出所有 Epic
-   `/pm:epic-show` —— 展示 Epic 及其任务
-   `/pm:epic-status [name]` —— 查看某个 Epic 的进度
-   `/pm:epic-close` —— 标记 Epic 为已完成
-   `/pm:epic-edit` —— 编辑 Epic 详情
-   `/pm:epic-refresh` —— 根据任务更新 Epic 进度
-   `/pm:epic-start` —— 启动并行 Agent 执行

___

📝 **Issue 命令**

-   `/pm:issue-show` —— 展示某个 Issue 及子任务
-   `/pm:issue-status` —— 查看 Issue 状态
-   `/pm:issue-start` —— 启动专用 Agent 开始处理 Issue
-   `/pm:issue-sync` —— 将 Issue 更新同步到 GitHub
-   `/pm:issue-close` —— 标记 Issue 为完成
-   `/pm:issue-reopen` —— 重新打开已关闭的 Issue
-   `/pm:issue-edit` —— 编辑 Issue 详情
-   `/pm:issue-analyze` —— 分析 Issue，发现可并行的子任务

___

🔄 **工作流命令**

-   `/pm:next` —— 显示下一个优先级最高的任务
-   `/pm:status` —— 查看整个项目的总体进度面板
-   `/pm:standup` —— 生成每日站会报告
-   `/pm:blocked` —— 显示所有被阻塞的任务
-   `/pm:in-progress` —— 列出正在进行中的任务

___

🔗 **同步命令**

-   `/pm:sync` —— 与 GitHub 双向完全同步
-   `/pm:import` —— 导入已有的 GitHub Issues

___

🔧 **维护命令**

-   `/pm:validate` —— 检查系统完整性
-   `/pm:clean` —— 归档已完成的工作
-   `/pm:search` —— 全局搜索所有内容

___

⚙️ **设置命令**

-   `/pm:init` —— 安装依赖并配置 GitHub
-   `/pm:help` —— 显示帮助信息

___

💡 **小贴士**

-   使用 `/pm:next` 快速找到可做的任务
-   使用 `/pm:status` 查看项目整体情况
-   标准 Epic 流程：`prd-new → prd-parse → epic-decompose → epic-sync`
-   查看 `README.md` 获取完整文档

___