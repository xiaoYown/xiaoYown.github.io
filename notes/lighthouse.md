[参考](https://mp.weixin.qq.com/s/o70cgce4jL17NAThMFctRQ)

> 提起性能优化 很多人眼前浮现的面试经验是不是历历在目呢？反正, 性能优化在我看来他永远是前端领域的热度之王.

### 性能优化标准

既然说性能优化, 那他总得有一个公认的标准, 这就是我们很多次听到的 Lighthouse

在很多单位, 都有着自己的性能监控平台, 我们只需要引入相应的 sdk, 那么在平台上就能分析出你页面的存在的性能问题, 大家是不是学的很神奇！

其实除了苛刻的业务, 需要特殊的定制, 大多数的情况下我们单位的性能优化平台本质上其实就是利用无头浏览器（Puppeteer）跑 Lighthouse.

理解了我们单位的性能监控平台的原理之后, 我们就能针对性的做性能优化, 也就是面向 Lighthouse 编程

### Lighthouse 介绍

lighthouse 是 Google Chrome 推出的一款开源自动化工具, 它可以搜集多个现代网页性能指标, 分析 Web 应用的性能并生成报告, 为开发人员进行性能优化的提供了参考方向.

说起 Lighthouse 在现代的谷歌浏览器中业已经集成

他可以分析出我们的页面性能, 通过几个指标

Lighthouse 会衡量以下性能指标项:

- 首次内容绘制（First Contentful Paint）. 即浏览器首次将任意内容（如文字、图像、canvas 等）绘制到屏幕上的时间点.
- 可交互时间（Time to Interactive）. 指的是所有的页面内容都已经成功加载, 且能够快速地对用户的操作做出反应的时间点.
- 速度指标（Speed Index）. 衡量了首屏可见内容绘制在屏幕上的速度. 在首次加载页面的过程中尽量展现更多的内容, 往往能给用户带来更好的体验, 所以速度指标的值约小越好.
- 总阻塞时间（Total Blocking Time）. 指 First Contentful Paint 首次内容绘制 (FCP)与 Time to Interactive 可交互时间 (TTI)之间的总时间
- 最大内容绘制（Largest Contentful Paint）. 度量标准报告视口内可见的最大图像或文本块的呈现时间
- 累积布局偏移（# Cumulative Layout Shift）. 衡量的是页面整个生命周期中每次元素发生的非预期布局偏移得分的总和. 每次可视元素在两次渲染帧中的起始位置不同时, 就说是发生了 LS（Layout Shift）.

在一般情况下, 据我的经验, 由于性能监控平台的和本地平台的差异, 本地可能要达到 70 分, 线上才有可能达到及格的状态,如果有性能优化的需求时, 大家酌情处理即可（不过本人觉得, 及格即可, 毕竟大学考试有曰: 60 分万岁, 61 分浪费, 传承不能丢, 咱们要把更多的时间, 放到更重要的事情上来!）

### 通用常规优化手段

lighthouse 的的牛 x 之处就是它能找出你页面中的一些常规的性能瓶颈, 并提出优化建议.

于是针对这些优化建议, 我们需要做一些常规的优化, 例如:

- 减少未使用的 javascript
- 移出阻塞渲染的资源
- 图片质量压缩
- 限制使用字体数量, 尽可能少使用变体
- 优化关键渲染路径: 只加载当前页面渲染所需的必要资源, 将次要资源放在页面渲染完成后加载

### 通用性能优化分析

我们知道 lighthouse 中有六个性能指标, 而在这六个指标中, LCP、 FCP、speed index、 这三个指数尤为重要, 因为在一般情况下 这个三个指标会影响 TTI、TBT、CLS 的分数

所以在我们在优化时, 需要提高 LCP、 FCP 和 speedIndex 的分数, 经过测试, 即使是空页面也会有时间上的损耗, 初始分数基本都是 0.8 秒

注意: 需要值得大家注意的是, 我们当前所有测试全部建立在, 移动端（之所以用移动端, 是由于 pc 的强大算力, 很少有性能瓶颈）的基础上,并且页面上必须有一下内容, 才能得出分数, 内容必须包括一下的一种或者多种

- 内嵌在 svg 元素内的 image 元素
- video 元素（使用封面图像）
- 通过 url()[8]函数（而非使用 CSS 渐变[9]）加载的带有背景图像的元素
- 包含文本节点或其他行内级文本元素子元素的块级元素[10].

否则就会有如下错误

```
此次 Lighthouse 运行并不限制, 原因如下:
 该网页未渲染任何内容, 请确保在网页加载过程中让浏览器窗口始终位于前台, 然后重试.
```

接下来我们就从 LCP、 FCP 和 speedIndex 这三个指标入手

#### FCP（First Contentful Paint）

顾名思义就是首次内容绘制, 也就是页面最开始绘制内容的时间, 但是由于我们现在开发的页面都是 spa 应用, 所以, 框架层面的初始化是一定会有一定的性能损耗的, 以 vue-cli 搭建的脚手架为例, 当我初始化空的脚手架, 打包后上传 cdn 部署, FCP 就会从 0.8s 提上到 1.5 秒, 由此可见 vue 的 diff 也不是免费的他也会有性能上的损耗

在优化页面的内容之前我们声明三个前提:

1. 提高 FCP 的时间其实就是在优化关键渲染路径[11]
2. 如果它是一个样式文件（CSS 文件）, 浏览器就必须在渲染页面之前完全解析它（这就是为什么说 CSS 具有渲染阻碍性）
3. 如果它是一个脚本文件（JavaScript 文件）, 浏览器必须: 停止解析, 下载脚本, 并运行它. 只有在这之后, 它才能继续解析, 因为 JavaScript 脚本可以改变页面内容（特别是 HTML）. （这就是为什么说 JavaScript 阻塞解析）

针对以上的用例测试, 我们发现, 无论我们怎么优化, 框架本身的性能损耗是无法抹除的, 我们唯一能做的就是让框架更早的去执行初始化, 并且初始化更少的内容, 可做的优化手段如下:

1. 所有初始化用不到的 js 文件全部走异步加载, 也就是加上 defer 或者 asnyc , 并且一些需要走 cdn 的第三方插件需要放在页面底部（因为放在顶部, 他的解析会阻止 html 的解析, 从而影响 css 等文件的下载, 这也是雅虎军规的一条）
2. js 文件拆包, 以 vue-cli 为例, 一般情况下我们可以通过 cli 的配置 splitChunks 做代码分割, 将一些第三方的包走 cdn, 或者拆包. 如果有路由的情况下将路由做拆包处理, 保证每个路由只加载当前路由对应的 js 代码
3. 优化文件大小 减少字体包、css 文件、以及 js 文件的大小（当然这些 脚手架默认都已经做了）
4. 优化项目结构, 每个组件的初始化都是有性能损耗的, 在在保证可维护性的基础上, 尽量减少初始化组件的加载数量
5. 网络协议层面的优化, 这个优化手段需要服务端配合纯前端已经无法达到, 在现在云服务器盛行的时代,自家单位一般都会默认在云服务器中开启这些优化手段, 比如开启 gzip, 使用 cdn 等等

其实说来说去, 提高 FCP 的核心只有理念之后两个 减少初始化视图内容和 减少初始化下载资源大小

#### LCP(Largest Contentful Paint)

顾名思义就是最大内容绘制, 何时报告 LCP,官方是这样说的

为了应对这种潜在的变化, 浏览器会在绘制第一帧后立即分发一个 largest-contentful-paint 类型的 PerformanceEntry[12], 用于识别最大内容元素. 但是, 在渲染后续帧之后, 浏览器会在最大内容元素发生变化时分发另一个 PerformanceEntry.

例如, 在一个带有文本和首图的网页上, 浏览器最初可能只渲染文本部分, 并在此期间分发一个 largest-contentful-paint 条目, 其 element 属性通常会引用一个\<p\>或\<h1\> . 随后, 一旦首图完成加载, 浏览器就会分发第二个 largest-contentful-paint 条目, 其 element 属性将引用\<img\> .

需要注意的是, 一个元素只有在渲染完成并且对用户可见后才能被视为最大内容元素. 尚未加载的图像不会被视为"渲染完成". 在字体阻塞期[13]使用网页字体的文本节点亦是如此. 在这种情况下, 较小的元素可能会被报告为最大内容元素, 但一旦更大的元素完成渲染, 就会通过另一个 PerformanceEntry 对象进行报告.

其实用大白话解释就是, 通常情况下, 图片、视频以及大量文本绘制完成后就会报告 LCP

理解了这一点, 的优化手段就明确了,尽量减少这些资源的大小就可以了, 经过测试, 减少首屏渲染的图片以及视频内容大小后, 整体分数显著提高, 提供一些优化方法:

1. 本地图片可以使用在线压缩工具自己压缩 推荐 tinypng.com[14]
2. 接口中附带图片, 一般情况下单位中都有对应的 oss 或者 cdn 传参配置通过地址栏传参方式控制图片质量
3. 图片懒加载

#### SpeedIndex（速度指数）

Speed Index 采用可视页面加载的视觉进度, 计算内容绘制速度的总分. 为此, 首先需要能够计算在页面加载期间, 各个时间点“完成”了多少部分.

在 WebPagetest 中, 通过捕获在浏览器中加载页面的视频并检查每个视频帧（在启用视频捕获的测试中, 每秒 10 帧）来完成的, 这个算法在下面有描述, 但现在假设我们可以为每个视频帧分配一个完整的百分比（在每个帧下显示的数字）

以上是官方解释的计算方式, 其实通俗的将, 所谓速度指数就是衡量页面内容填充的速度

经过测试, 跟 LCP 相同, 图片以及视频内容对于 SpeedIndex 的影响巨大, 所有优化方向, 通之前一致, 总的来说, 只要提高 LCP 以及 FCP 的时间 SpeedIndex 的时间就会有显著提高

不过需要注意的是, 接口的速度也会影响 SpeedIndex 的时间, 由于 AJAX 流行的今天, 我们大多数的数据都是使用接口拉取. 如果接口速度过慢, 他就会影响你页面的初始渲染, 导致性能问题, 所以, 在做性能优化的同时, 请求后端伙伴协助, 也是性能优化的一个方案

#### 排查性能瓶颈

上述分析, 根据三个指标提供了一些常规的优化手段, 那么在这些优化手段中, 有的你可以立马排查到, 并且优化例如:

1. 优化图像, 优化字体大小
2. 跟服务端配合利用浏览器缓存机制.启用 cdn、启用 gzip 等
3. 减少网络协议过程中的消耗, 减少 http 请求、减少 dns 查询、避免重定向
4. 优化关键渲染路径, 异步加载 js 等

但是有的优化手段我们不容易排查, 因为他是打在包里面的, 这个 js 文件包含了很多逻辑怎么办, 这里我有两个手段或许能够帮助排查出性能瓶颈发生在哪里:

> 分析包内容

在通常情况下, 我们无法判断的优化点, 都是在打包后, 我们无法分析出, 那些东西不是我们在首屏必须需要的, 从而不能做出针对新的优化, 为了解决当前问题, 各大 bundle 厂商也都有各自的分析包的方案

以 vue-cli 为例:

```
"report": "vue-cli-service build --report"
```

我们只需要在脚手架中提供以上命令, 就能在打包时生成, 整个包的分析文件

在打包后就能分析出打包后的 js 文件他包含什么组件, 如此以来, 我们就能知道那些文件是没必要同步加载的, 或者走 cdn 的, 通过配置将他单独的隔离开来, 从而找出性能的问题

> 利用 chorme devtool 的代码覆盖率

如下图所示,
图片
利用 devtool 的代码覆盖率检查就能知道那些 js 或者 css 文件的代码没有被使用过, 结合包内容的分析, 我们就能大概的猜出性能的瓶颈在哪里从而做相应的特殊处理

性能优化一直是一个很火的话题, 不管从面试以及工作中都非常重要, 有了这些优化的点, 你在写代码或者优化老项目时都能游刃有余, 能提前考虑到其中的一些坑, 并且规避.
但是大家需要明白的是, 不要为了性能优化而性能优化, 我们在要因地制宜, 在不破坏项目可维护性的基础上去优化, 千万不要你优化个项目性能是好了, 但是大家都看不懂了, 这就有点得不偿失了, 还是那句话, 60 分万岁 61 份浪费, 差不多得了, 把经历留着去干更重要的事情！

### 参考资料

1. [lighthouse](https://link.zhihu.com/?target=https://github.com/GoogleChrome/lighthouse)
2. [首次内容绘制](https://web.dev/i18n/zh/fcp/)
3. [可交互时间](https://web.dev/i18n/zh/tti/)
4. [速度指标](https://web.dev/speed-index/)
5. [总阻塞时间](https://web.dev/i18n/zh/tbt/)
6. [最大内容绘制](https://web.dev/i18n/zh/lcp/)
7. [累积布局偏移](https://web.dev/i18n/zh/cls/)
8. [url()](<https://developer.mozilla.org/docs/Web/CSS/url()>)
9. [CSS 渐变](https://developer.mozilla.org/docs/Web/CSS/CSS_Images/Using_CSS_gradients)
10. [块级元素](https://developer.mozilla.org/docs/Web/HTML/Block-level_elements)
11. [关键渲染路径](https://developer.mozilla.org/zh-CN/docs/Web/Performance/Critical_rendering_path)
12. [PerformanceEntry](https://developer.mozilla.org/docs/Web/API/PerformanceEntry)
13. [字体阻塞期](https://developer.mozilla.org/docs/Web/CSS/@font-face/font-disply#The_font_display_timeline)
14. [tinypng.com](https://tinypng.com/)
