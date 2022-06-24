### 柯里化

> 柯里化, 可以理解为提前接收部分参数, 延迟执行, 不立即输出结果, 而是返回一个接受剩余参数的函数. 因为这样的特性, 也被称为部分计算函数. 柯里化, 是一个逐步接收参数的过程.

- 提前绑定好函数里面的某些参数, 达到参数复用的效果, 提高了适用性
- 固定易变因素
- 延迟计算

```ts
const curry = (fn: any) => {
  let allArgs: any[] = [];

  const next: any = (...args: any[]) => {
    allArgs = allArgs.concat(args);
    return next;
  };
  // 字符类型
  next.toString = function () {
    return fn.apply(null, allArgs);
  };
  // 数值类型
  next.valueOf = function () {
    return fn.apply(null, allArgs);
  };

  return next;
};
```

### 反柯里化

> 反柯里化, 是一个泛型化的过程. 它使得被反柯里化的函数, 可以接收更多参数. 目的是创建一个更普适性的函数, 可以被不同的对象使用. 有鸠占鹊巢的效果.

```ts
function uncurry(fn) {
  return function (context, ...args) {
    // 改变 this, 让函数执行, 把参数传入
    // 将 fn 执行, 并将后续参数传递给 apply 方法
    return Reflect.apply(fn, context, args);
  };
}

let join = uncurry(Array.prototype.join);

let r = join([1, 2, 3], ":");
```
