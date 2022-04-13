### 类型判断

```ts
const callToString = (e: any): string => Object.prototype.toString.call(e);

export const isNull = (obj): boolean => callToString(obj) === "[object Null]";

export const isUndefined = (obj): boolean =>
  callToString(obj) === "[object Undefined]";

export const isString = (obj): boolean =>
  callToString(obj) === "[object String]";

export const isNumber = (obj): boolean =>
  callToString(obj) === "[object Number]";

export const isBoolean = (obj): boolean =>
  callToString(obj) === "[object Boolean]";

export const isObject = (obj): boolean =>
  callToString(obj) === "[object Object]";

export const isArray = (obj): boolean => callToString(obj) === "[object Array]";

export const isPromise = (obj): boolean =>
  callToString(obj) === "[object Promise]";
```
