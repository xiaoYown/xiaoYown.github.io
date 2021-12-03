### 断言

(?!pattern) - 零宽负向先行断言
(?<!pattern) - 零宽负向后行断言

### eg - 1

```js
// 以 <div> 起 </div> 结束, 匹配中间字符
"<div>11</div><div>22</div>".match(/(?<=<div>)[\s\S]*?(?=<\/div>)/g);
```
