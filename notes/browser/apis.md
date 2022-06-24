[来源](https://juejin.cn/post/7028744289890861063)

### MutationObserver

> MutationObserver 是一个可以监听 DOM 结构变化的接口. 当 DOM 对象树发生任何变动时, MutationObserver 会得到通知.

**MutationObserver 是一个构造器, 接受一个 callback 参数, 用来处理节点变化的回调函数, 返回两个参数: **

- mutations: 节点变化记录列表（sequence<MutationRecord>）
- observer: 构造 MutationObserver 对象.

**MutationObserver 对象有三个方法, 分别如下: **

- observe: 设置观察目标, 接受两个参数, target: 观察目标, options: 通过对象成员来设置观察选项
- disconnect: 阻止观察者观察任何改变
- takeRecords: 清空记录队列并返回里面的内容

**demo**

```js
//选择一个需要观察的节点
var targetNode = document.getElementById("root");

// 设置observer的配置选项
var config = { attributes: true, childList: true, subtree: true };

// 当节点发生变化时的需要执行的函数
var callback = function (mutationsList, observer) {
  for (var mutation of mutationsList) {
    if (mutation.type == "childList") {
      console.log("A child node has been added or removed.");
    } else if (mutation.type == "attributes") {
      console.log("The " + mutation.attributeName + " attribute was modified.");
    }
  }
};

// 创建一个observer示例与回调函数相关联
var observer = new MutationObserver(callback);

//使用配置文件对目标节点进行观测
observer.observe(targetNode, config);

// 停止观测
observer.disconnect();
```

**observe 方法中 options 参数有已下几个选项: **

- childList: 设置 true, 表示观察目标子节点的变化, 比如添加或者删除目标子节点, 不包括修改子节点以及子节点后代的变化
- attributes: 设置 true, 表示观察目标属性的改变
- characterData: 设置 true, 表示观察目标数据的改变
- subtree: 设置为 true, 目标以及目标的后代改变都会观察
- attributeOldValue: 如果属性为 true 或者省略, 则相当于设置为 true, 表示需要记录改变前的目标属性值, 设置了 attributeOldValue 可以省略 attributes 设置
- characterDataOldValue: 如果 characterData 为 true 或省略, 则相当于设置为 true,表示需要记录改变之前的目标数据, 设置了 characterDataOldValue 可以省略 characterData 设置
- attributeFilter: 如果不是所有的属性改变都需要被观察, 并且 attributes 设置为 true 或者被忽略, 那么设置一个需要观察的属性本地名称（不需要命名空间）的列表

**MutationObserver 有以下特点: **

它等待所有脚本任务完成后才会运行, 即采用异步方式
它把 DOM 变动记录封装成一个数组进行处理, 而不是一条条地个别处理 DOM 变动.
它即可以观察发生在 DOM 节点的所有变动, 也可以观察某一类变动

当 DOM 发生变动会触发 MutationObserver 事件. 但是, 它与事件有一个本质不同: 事件是同步触发, 也就是说 DOM 发生变动立刻会触发相应的事件；MutationObserver 则是异步触发, DOM 发生变动以后, 并不会马上触发, 而是要等到当前所有 DOM 操作都结束后才触发.

---

### IntersectionObserver

网页开发时, 常常需要了解某个元素是否进入了"视口"（viewport）, 即用户能不能看到它.
传统的实现方法是, 监听到 scroll 事件后, 调用目标元素的 getBoundingClientRect()方法, 得到它对应于视口左上角的坐标, 再判断是否在视口之内. 这种方法的缺点是, 由于 scroll 事件密集发生, 计算量很大, 容易造成性能问题.
目前有一个新的 IntersectionObserver API, 可以自动"观察"元素是否可见, Chrome 51+ 已经支持. 由于可见（visible）的本质是, 目标元素与视口产生一个交叉区, 所以这个 API 叫做"交叉观察器".

**demo**

```js
var io = new IntersectionObserver(callback, option);

// 开始观察
io.observe(document.getElementById("example"));

// 停止观察
io.unobserve(element);

// 关闭观察器
io.disconnect();

// 观察多个节点
io.observe(elementA);
io.observe(elementB);
```

> 目标元素的可见性变化时, 就会调用观察器的回调函数 callback. callback 一般会触发两次. 一次是目标元素刚刚进入视口（开始可见）, 另一次是完全离开视口（开始不可见）.

callback 函数的参数（entries）是一个数组, 每个成员都是一个 IntersectionObserverEntry 对象. 举例来说, 如果同时有两个被观察的对象的可见性发生变化, entries 数组就会有两个成员.

- time: 可见性发生变化的时间, 是一个高精度时间戳, 单位为毫秒
- target: 被观察的目标元素, 是一个 DOM 节点对象
- isIntersecting: 目标是否可见
- rootBounds: 根元素的矩形区域的信息, getBoundingClientRect()方法的返回值, 如果没有根元素（即直接相对于视口滚动）, 则返回 null
- boundingClientRect: 目标元素的矩形区域的信息
- intersectionRect: 目标元素与视口（或根元素）的交叉区域的信息
- intersectionRatio: 目标元素的可见比例, 即 intersectionRect 占 boundingClientRect 的比例, 完全可见时为 1, 完全不可见时小于等于 0

---

### getComputedStyle

DOM2 Style 在 document.defaultView 上增加了 getComputedStyle()方法, 该方法返回一个 CSSStyleDeclaration 对象（与 style 属性的类型一样）, 包含元素的计算样式.

```js
document.defaultView.getComputedStyle(element[,pseudo-element])
// or
window.getComputedStyle(element[,pseudo-element])
```

**与 style 的异同**

getComputedStyle 和 element.style 的相同点就是二者返回的都是 CSSStyleDeclaration 对象. 而不同点就是:

- element.style 读取的只是元素的内联样式, 即写在元素的 style 属性上的样式；而 getComputedStyle 读取的样式是最终样式, 包括了内联样式、嵌入样式和外部样式.
- element.style 既支持读也支持写, 我们通过 element.style 即可改写元素的样式. 而 getComputedStyle 仅支持读并不支持写入. 我们可以通过使用 getComputedStyle 读取样式, 通过 element.style 修改样式

---

### getBoundingClientRect

getBoundingClientRect() 方法返回元素的大小及其相对于视口的位置.

```js
let DOMRect = object.getBoundingClientRect();
```

它的返回值是一个 DOMRect 对象, 这个对象是由该元素的 getClientRects() 方法返回的一组矩形的集合, 就是该元素的 CSS 边框大小. 返回的结果是包含完整元素的最小矩形, 并且拥有 left, top, right, bottom, x, y, width, 和 height 这几个以像素为单位的只读属性用于描述整个边框. 除了 width 和 height 以外的属性是相对于视图窗口的左上角来计算的.

---

### requestAnimationFrame

window.requestAnimationFrame() 告诉浏览器——你希望执行一个动画, 并且要求浏览器在下次重绘之前调用指定的回调函数更新动画.

与 setTimeout 相比, requestAnimationFrame 最大的优势是由系统来决定回调函数的执行时机. 具体一点讲, 如果屏幕刷新率是 60Hz,那么回调函数就每 16.7ms 被执行一次, 如果刷新率是 75Hz, 那么这个时间间隔就变成了 1000/75=13.3ms, 换句话说就是, requestAnimationFrame 的步伐跟着系统的刷新步伐走. 它能保证回调函数在屏幕每一次的刷新间隔中只被执行一次, 这样就不会引起丢帧现象, 也不会导致动画出现卡顿的问题.

**优点**

- **CPU 节能:** 使用 setTimeout 实现的动画, 当页面被隐藏或最小化时, setTimeout 仍然在后台执行动画任务, 由于此时页面处于不可见或不可用状态, 刷新动画是没有意义的, 完全是浪费 CPU 资源. 而 requestAnimationFrame 则完全不同, 当页面处理未激活的状态下, 该页面的屏幕刷新任务也会被系统暂停, 因此跟着系统步伐走的 requestAnimationFrame 也会停止渲染, 当页面被激活时, 动画就从上次停留的地方继续执行, 有效节省了 CPU 开销.

- **函数节流:** 在高频率事件(resize,scroll 等)中, 为了防止在一个刷新间隔内发生多次函数执行, 使用 requestAnimationFrame 可保证每个刷新间隔内, 函数只被执行一次, 这样既能保证流畅性, 也能更好的节省函数执行的开销. 一个刷新间隔内函数执行多次时没有意义的, 因为显示器每 16.7ms 刷新一次, 多次绘制并不会在屏幕上体现出来.
