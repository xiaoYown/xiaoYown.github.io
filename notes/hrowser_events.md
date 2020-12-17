[所有事件](https://blog.csdn.net/weixin_41697143/article/details/85211424)

### deviceorientation
```js
// 检查手机是否支持
if (window.DeviceOrientationEvent) {
  window.addEventListener('deviceorientation', DeviceOrientationHandler, false);
} else {
  alert("您的浏览器不支持 HTML5 DeviceOrientation 接口");
}
```

### orientationchange

移动端的设备提供了一个事件：orientationChange事件

这个事件是苹果公司为safari中添加的。以便开发人员能够确定用户何时将设备由横向查看切换为纵向查看模式。

在设备旋转的时候，会触发这个事件

### offline

### online

### pagehide

### pageshow

### storage