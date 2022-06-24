[所有事件](https://blog.csdn.net/weixin_41697143/article/details/85211424)

## 最常见的类别

### 资源加载事件

| 事件名称     | 何时触发                                           |
| ------------ | -------------------------------------------------- |
| cached       | manifest 中列出的资源已经下载，应用程序现在已缓存. |
| error        | 资源加载失败时                                     |
| abort        | 正在加载资源已经被中止时                           |
| load         | 资源及其相关资源已完成加载.                        |
| beforeunload | window，document 及其资源即将被卸载.               |
| unload       | 文档或一个依赖资源正在被卸载.                      |

### 网络事件

| 事件名称 | 何时触发              |
| -------- | --------------------- |
| online   | 浏览器已获得网络访问. |
| offline  | 浏览器已失去网络访问. |

### 焦点事件

| 事件名称 | 何时触发               |
| -------- | ---------------------- |
| focus    | 元素获得焦点(不会冒泡) |
| blur     | 元素失去焦点(不会冒泡) |

### Websocket 事件

| 事件名称 | 何时触发                                        |
| -------- | ----------------------------------------------- |
| open     | WebSocket 连接已建立                            |
| message  | 通过 WebSocket 接收到一条消息                   |
| error    | WebSocket 连接异常被关闭(比如有些数据无法发送). |
| close    | WebSocket 连接已关闭                            |

### 页面事件

| 事件名称 | 何时触发                                                          |
| -------- | ----------------------------------------------------------------- |
| pagehide | A session history entry is being traversed from.                  |
| pageshow | A session history entry is being traversed to.                    |
| popstate | A session history entry is being navigated to (in certain cases). |

### CSS 动画事件

| 事件触发           | 何时触发                          |
| ------------------ | --------------------------------- |
| animationstart     | 某个 CSS 动画开始时触发           |
| animationend       | 某个 CSS 动画完成时触发           |
| animationiteration | 某个 CSS 动画完成后重新开始时触发 |

### 表单事件

| 事件名称 | 何时触发       |
| -------- | -------------- |
| reset    | 点击重置按钮时 |
| submit   | 点击提交按钮   |

### 打印机事件

| 事件名称    | 何时触发             |
| ----------- | -------------------- |
| beforeprint | 打印机已经就绪时触发 |
| afterprint  | 打印机关闭时触发     |

### 输入法合成文字事件

| 事件名称          | 何时触发           |
| ----------------- | ------------------ |
| compositionstart  | 开始输入           |
| compositionupdate | 输入合成内容更新   |
| compositionend    | 输入法结束文字合成 |

### 视图相关事件

| 事件名称         | 何时触发                                       |
| ---------------- | ---------------------------------------------- |
| fullscreenchange | 当浏览器进入或离开全屏时触发                   |
| fullscreenerror  | 在当前文档不能进入全屏模式，即使它被请求时触发 |
| resize           | 文档视图调整大小时会触发 resize 事件           |
| scroll           | 视图滚动发生滚动                               |

### 剪切板事件

| 事件名称 | 何时触发                                 |
| -------- | ---------------------------------------- |
| cut      | 已经剪贴选中的文本内容并且复制到了剪贴板 |
| copy     | 已经把选中的文本内容复制到了剪贴板       |
| paste    | 从剪贴板复制的文本内容被粘贴             |

```ts
document.addEventListener("paste", (event: ClipboardEvent) => {
  const { items = [], types = [] } = event?.clipboardData ?? {};

  types.forEach((item, index) => {
    switch (items[index].kind) {
      case "file":
        console.log(items[index].getAsFile());
        break;
      case "string":
        // 纯文本输出
        console.log(event?.clipboardData?.getData("text"));
        // 真实文本格式输入
        items[index].getAsString((data: string) => {
          console.log(item, data);
        });
        break;
    }
  });
});
```

### 键盘事件

| 事件名称 | 何时触发                                          |
| -------- | ------------------------------------------------- |
| keydown  | 按下任意按键                                      |
| keypress | 除 Shift, Fn, CapsLock 外任意键被按住. (连续触发) |
| keyup    | 释放任意按键                                      |

### 鼠标事件

| 事件名称          | 何时触发                                 |
| ----------------- | ---------------------------------------- |
| mouseenter        | 指针移到有事件监听的元素内               |
| mouseover         | 指针移到有事件监听的元素或者它的子元素内 |
| mousemove         | 指针在元素内移动时持续触发               |
| mousedown         | 在元素上按下任意鼠标按钮                 |
| mouseup           | 在元素上释放任意鼠标按键                 |
| click             | 在元素上按下并释放任意鼠标按键           |
| dblclick          | 在元素上双击鼠标按钮                     |
| contextmenu       | 右键点击 (右键菜单显示前).               |
| wheel             | 滚轮向任意方向滚动                       |
| mouseleave        | 指针移出元素范围外(不冒泡)               |
| mouseout          | 指针移出元素，或者移到它的子元素上       |
| select            | 文本被选中被选中                         |
| pointerlockchange | 鼠标被锁定或者解除锁定发生时             |
| pointerlockerror  | 可能因为一些技术的原因鼠标锁定被禁止时.  |

### 拖拽事件

| 事件名称  | 何时触发                                                                               |
| --------- | -------------------------------------------------------------------------------------- |
| dragstart | 用户开始拖动 HTML 元素或选中的文本                                                     |
| drag      | 正在拖动元素或文本选区(在此过程中持续触发，每 350ms 触发一次)                          |
| dragend   | 拖放操作结束 (松开鼠标按钮或按下 Esc 键)                                               |
| dragenter | 被拖动的元素或文本选区移入有效释放目标区                                               |
| dragover  | 被拖动的元素或文本选区正在有效释放目标上被拖动 (在此过程中持续触发，每 350ms 触发一次) |
| dragleave | 被拖动的元素或文本选区移出有效释放目标区                                               |
| drop      | 元素在有效释放目标区上释放                                                             |

### audio/video 元素事件

| 事件名称       | 何时触发                                                                                                                                                                                   |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| durationchange | HTMLMediaElement 的 duration 属性更新时被触发.                                                                                                                                             |
| loadedmetadata | The loadedmetadata event is fired when the metadata has been loaded.                                                                                                                       |
| loadeddata     | 媒体当前播放位置的视频帧(通常是第一帧)加载完成后触发.                                                                                                                                      |
| canplay        | 在终端可以播放媒体文件时(但估计还没有加载足够的数据来播放媒体直到其结束，即后续可能需要停止以进一步缓冲内容)被触发.                                                                        |
| canplaythrough | 在终端可以播放媒体文件时(估计已经加载了足够的数据来播放媒体直到其结束，而不必停止以进一步缓冲内容)被触发.                                                                                  |
| ended          | 在媒体回放或者媒体流因达到了媒体的未尾或者没有更多可用的数据而停止时被触发.                                                                                                                |
| emptied        | 当媒体变空时; 例如，如果媒体已经加载(或部分加载)，则发送此事件，并调用 load() 方法重新加载它                                                                                               |
| stalled(停滞)  | 当用户代理尝试获取媒体数据, 却没有如期获取到数据时.                                                                                                                                        |
| suspend        | 当媒体数据加载被暂停时.                                                                                                                                                                    |
| play           | 当 paused 属性由 true 转换为 false 时触发 play 事件，事件触发原因一般为 play() 方法调用，或者 autoplay 标签设置.                                                                           |
| playing        | playing 事件在播放准备开始时(之前被暂停或者由于数据缺乏被暂缓)被触发.                                                                                                                      |
| pause          | 当暂停媒体播放时 pause 事件触发， 并且媒体进入暂停状态，最常见的是通过 pause()方法来触发.                                                                                                  |
| waiting        | 由于暂时缺少数据而停止播放时会触发等待事件.                                                                                                                                                |
| seeking        | The seeking event is fired when a seek operation starts, meaning the Boolean seeking attribute has changed to true and the media is seeking a new position.                                |
| seeked         | The seeked event is fired when a seek operation completed, the current playback position has changed, and the Boolean seeking attribute is changed to false.                               |
| ratechange     | 播放速度改变时.                                                                                                                                                                            |
| timeupdate     | 这个事件的触发频率由系统决定，但是会保证每秒触发 4-66 次(前提是每次事件处理不会超过 250ms).鼓励用户代理根据系统的负载和处理事件的平均成本来改变事件的频率，保证 UI 更新不会影响视频的解码. |
| volumechange   | 音量发生改变时触发.                                                                                                                                                                        |

### 加载相关事件

| 事件名称  | 何时触发                                                                      |
| --------- | ----------------------------------------------------------------------------- |
| loadstart | Progress has begun.                                                           |
| progress  | In progress.                                                                  |
| error     | Progression has failed.                                                       |
| timeout   | Progression is terminated due to preset time expiring.                        |
| abort     | Progression has been terminated (not due to an error).                        |
| load      | Progression has been successful.                                              |
| loadend   | Progress has stopped (after "error", "abort" or "load" have been dispatched). |

### 传感器事件

| 事件名称          | 何时触发                 |
| ----------------- | ------------------------ |
| orientationchange | 设备的纵横方向改变时触发 |

### 存储事件节

### 更新事件节

### 值变化事件节

### 未分类的事件节

## 不常见 和 非标准分类节

- SVG 事件节
- 数据库事件节
- 通知事件节
- CSS 事件节
- 脚本事件节
- 菜单事件节
- 窗口事件节
- 文档事件节
- 弹出事件节
- Tab 事件节
- 电池事件节
- 呼叫事件节
- 传感器事件节
- 智能卡事件节
- 短信和 USSD 事件节
- 帧事件节
- DOM 变异事件节
- 触摸事件节
- 指针事件节
- 标准事件节
- 非标准事件节
- Mozilla 特定事件节
- 附加组件特定事件节
- 开发者工具特定事件
