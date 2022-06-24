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

const add = (...args: number[]) => {
  var sum = 0;
  for (var i = 0; i < args.length; i++) {
    sum += args[i];
  }
  return sum;
};

const curriedAdd = curry(add);

console.log(curriedAdd(1, 2)(2) + 0);
