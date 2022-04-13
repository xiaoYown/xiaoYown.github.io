```js
import { throttle, debounce } from "throttle-debounce";
// const { throttle, debounce } = require('throttle-debounce')

/**
 * 函数防抖
 * 函数防抖（debounce）： 当持续触发事件时，一定时间段内没有再触发事件，事件处理函数才会执行一次，
 *                      如果设定的时间到来之前，又一次触发了事件，就重新开始延时。
 */

// debounce(300, () => {
// 	console.log('debounce')
// });

/**
 * 函数节流
 * 函数节流（throttle）： 当持续触发事件时，保证一定时间段内只调用一次事件处理函数。
 *                      节流通俗解释就比如我们水龙头放水，阀门一打开，水哗哗的往下流，
 *                      秉着勤俭节约的优良传统美德，我们要把水龙头关小点，最好是如我们心意按照一定规律在某个时间间隔内一滴一滴的往下滴。
 */

let throttledTime = 0;
let throttledLimit = 3;

function stopThrottle() {
  if (throttledTime > throttledLimit) {
    clearInterval(throttledTimer);
    throttled.cancel();
  }
}

const throttled = throttle(1500, () => {
  throttledTime += 1;
  console.log("throttle");
  stopThrottle();
});

let throttledTimer = setInterval(throttled, 100);
```
