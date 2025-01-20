# 微前端或插件机制中的沙箱与绕过手段

在一些微前端或“插件机制”场景中，常见的做法是使用 `window` 代理（或者“沙箱”）来拦截插件对全局对象的访问，避免它直接读写宿主页面的真实 `window`。这往往通过 `Proxy`、`Object.defineProperty`、或 `with` 语法等手段创建一个“假 `window`”对象，让插件脚本在其中运行。

不过，由于浏览器环境的复杂性，以及 JavaScript 对全局对象的多种引用方式，这种“代理沙箱”并不能 100% 隔离所有情况。插件依然有可能通过一些“绕过”手段拿到真正的全局对象，从而对宿主环境造成影响。以下是比较常见的绕过方式或潜在风险点：

## 1. 访问 `window.top` / `window.parent`

- 在多数浏览器环境下，`window.top` 和 `window.parent` 指向最顶层/父级框架的 `window`，往往并没有被代理重写（除非对这两个属性也做了很深的劫持）。
- 如果插件在同源环境下使用 `window.top.xxx`，就可能访问到真正的全局对象或更高层的 `window`。
- 类似 `window.frameElement`、`window.opener` 等也可能拿到更真实的宿主对象。

### 如何应对

- 如果无法使用 iframe 做强隔离，就需要在沙箱实现里进一步对 `top`、`parent`、`frameElement`、`opener` 等属性做防护、代理甚至冻结。但由于同源策略或业务需求，这可能带来额外复杂度。

## 2. 通过原生 API 获得真实的 `window` 或 `document`

有些 DOM 或浏览器 API 会暴露真正的全局上下文，比如：

- `document.defaultView` 通常直接等于真实的 `window`。
- `document.ownerDocument.defaultView`（对于某些子 DOM 节点操作）。
- `event.target.ownerDocument.defaultView`（在事件回调中，若拿到真实的事件对象）。
- `Element.prototype.ownerDocument.defaultView`。

如果沙箱只在 `window` 级别做代理，而没改写 `document` 或其他 DOM 原型链上的属性，插件可能通过这些 DOM API 间接拿到真实 `window`。

## 3. 通过函数构造绕过（`Function` / `eval` / `setTimeout` 等）

一些沙箱实现会替换或拦截全局 `eval`，但 JavaScript 里还有以下变体：

- `Function("return this")()`
- `(0, eval)("this")`
- `setTimeout("console.log(this)", 0)` 或 `setInterval("console.log(this)", 1000)`
- `new Function(...)`

### 如何应对

- 在沙箱中显式拦截 / 重写 `Function`、`eval`、`setTimeout` 等与 `this` 绑定相关的地方，并确保它们不会暴露真实 `window`。这往往复杂度高、兼容风险大。

## 4. 通过 `blob:` / `data:` URL 注入新脚本

- 插件可以创建一个 `<script src="blob:...">` 或 `<script src="data:...">`，然后在新脚本里执行代码。
- 如果这些新脚本在沙箱机制外部加载，就可能拿到默认的全局对象。
- 甚至通过 `<iframe src="javascript:...">` 来嵌入脚本，并访问 `iframe.contentWindow`。

## 5. 使用存储对象逃逸：`localStorage` / `sessionStorage` / `IndexedDB` 等

- 如果沙箱逻辑依赖注入时机，一些场景下插件代码可能先行执行、写入全局存储，再在沙箱外部被读取。
- 或者通过 `new Worker(...)` 等方式，让 Worker 与真实全局通信（视实现而定）。

## 6. 修改原生原型或共享对象

- 如果沙箱没有对“全局原型链”（如 `Array.prototype`、`Object.prototype`、`HTMLElement.prototype` 等）进行防护，插件可以在这些原型上注入代码，间接影响宿主应用。

## 7. 嵌套或第三方脚本内的引用

- 如果插件 A 加载了第三方库 B，而库 B 在某些地方持有真实 `window` 的引用，就可能泄露给后续的插件。

## 8. CSS/DOM 边通道攻击

- 利用 CSS 或 DOM 属性注入来触发宿主页面脚本执行。这类更像 XSS 攻击，虽然不一定是直接拿到 `window`，但可能影响宿主行为。

## 9. 浏览器特性 / DevTools 扩展

- 用户/插件能使用 DevTools 或浏览器扩展权限（如 Tampermonkey），直接注入/操作真实页面。这通常超出沙箱机制的控制范围。

---

## 总体思路：沙箱 ≠ 100% 隔离

以上种种方式说明，如果插件刻意绕过“window 代理沙箱”，而且你没有封锁所有可能泄露真实全局的 API，通常还是有漏洞可钻。

### 常见认识：

- “window 代理”更多用于减少冲突、隔离命名空间。
- **适合团队内部约定**“插件不要刻意干坏事”，这样能大幅降低插件相互污染。
- 若要 100% 隔离，iframe 依旧是最靠谱的选择。
  - 在同源 iframe 里，也得注意 `window.parent`、`window.top` 是否同源可访问。
  - 若要极端安全，需要跨域 + `sandbox` 属性。

### 可结合 Shadow DOM

- Shadow DOM 主要解决样式和部分 DOM 事件的隔离，不会禁止脚本访问全局对象。
- 如果需求是避免样式冲突，Shadow DOM 即可；要隔离 JS，就需要更复杂的代理+封装。

### 对“软沙箱”要有清晰的认知

- 它能解决绝大部分“无意”干扰，但防不了“恶意”绕过。
- 在企业内部应用或“半信任”插件环境下适用。
- 如果是面对完全不可信的第三方代码，通常需要更强的沙箱（iframe、Worker 或浏览器扩展机制）。

---

## TL;DR

- `window` 代理沙箱可以在大多数常规场景下限制插件对宿主应用的干扰。
- 但它不是严格的安全边界，插件可以通过多种方式获取真实 `window`。
- 要实现真正的全局隔离，需要使用 `<iframe>`（同源/跨域）或者 Web Worker。
- 将来 ShadowRealm 等特性成熟，或许会有更原生、更完善的同进程沙箱。
