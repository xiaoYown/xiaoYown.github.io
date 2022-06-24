#### 项目工程化

- 硬盘作大小写区分分区
- 编辑器配置 LF 换行(LF: "\n", Linefeed; CRLF: "\r\n", Carriage Return & Linefeed)
- eslint 代码检验
- prettier 代码美化
- husky 提交校验
- monorepo 项目模块拆分以及包管理
- 提交规范 commitizen
- changelog 生成, cz-lerna-changelog(使用 husky 保证全员提交规范)
- 国际化
- mock
- 文档管理(有大版本区分)

#### 必要准备

- 框架, UI 库选择
- axios 封装, 接口抽离为 package 统一管理
- 项目主题色
- 样式: tailwindcss/less/sass/stylus
- 项目公共依赖分离
- 生成前端最终文件 nginx 配置

#### 交互规范

- 点击请求, 需有按钮 loading 状态
- 加载请求, 加载部分使用 skeleton|spin 表示加载状态
- UI 销毁前, pending 状态请求需主动取消
- 请求失败状态处理(协议失败状态公共 UI, 服务具体失败状态 UI, 超时 UI)
- 尽量避免弹窗展示处理结果(体验不佳)
- 接口请求测试页面(保证所有接口返回 200, 处理结果不为协议报错)
- 高频触发交互根据需求使用 防抖/节流
- 有需求情形使用 Accessibility 无障碍(https://www.w3.org/WAI/ARIA/apg/)

#### 无障碍(有条件则做)

> 关心可访问性表露出良好的道德品质，它提升了你的公众形象

- https://www.w3.org/WAI/ARIA/apg/
- https://developer.mozilla.org/zh-CN/docs/Learn/Accessibility/

#### 特殊准备:

- 项目二级目录

```
目的: 方便过网关二级目录项目部署

统一管理:
所有使用二级目录的请求, 均来源于同一个文件. 统一修改文件, 配置位置: 可导入最终打包的配置文件.

分散管理: 所有请求需使用二级目录封装
- 异步请求
- 带请求标签
- 文件上传依赖
- 封装全局 url 转换函数
- open|location.replace|location.href 跳转封装
```

nginx 二级目录配置:

```
server {
  listen 80;
  location ^~ /projectid/ {
    proxy_pass http://localhost:84/;
  }
}
```

#### 优化相关

- dns-prefetch
