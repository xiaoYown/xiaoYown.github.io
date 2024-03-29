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

export const isBigInt = (obj): boolean =>
  callToString(obj) === "[object BigInt]";

export const isPromise = (obj): boolean =>
  callToString(obj) === "[object Promise]";
```

### 字符串转数字

```ts
/**
 * 完成Boolean、Null、String转换为Number类型，并支持以向上取整、向下取整、四舍五入的方式保留指定数位
 * @param {Boolean || Null || String || Number} val 转换目标
 * @param {Number} precision 精确数位，默认保留两位小数，根据项目经验暂定最多支持9位小数
 * @param {String} type 转换方式，默认round四舍五入，同时支持ceil向上取整、floor向下取整
 * @return 返回转换后的数字所对应的字符串
 */
export const toNumber = (val, precision = 2, type = "round") => {
  // 刨除非Boolean、Null、String、Number这四种的类型
  // typeof null === 'object'
  if (
    typeof val !== "boolean" &&
    typeof val !== "string" &&
    typeof val !== "number" &&
    val !== null
  ) {
    throw "toNumber() can not convert val argument to number";
  }

  // 刨除是字符串类型但不能解析成数字的输入
  if (typeof val === "string" && isNaN(Number(val))) {
    throw "toNumber() can not convert val argument to number";
  }

  // 校验 precision 类型及大小：按项目经验首先满足是数字类型，介于0--9之间的整数
  if (typeof precision !== "number") {
    throw "toNumber() precision argument must be Integer and between 0 and 9";
  }

  // 校验type是否为指定类型
  const types = ["round", "ceil", "floor"];
  if (!types.includes(type)) {
    throw 'toNumber() type argument must be one of "round", "ceil", "floor"';
  }

  let target =
    Math.floor(Number(val)) + Number((Number(val) % 1).toPrecision(12));

  // 处理符号位
  let target_s = target < 0 ? "-" : "";
  target = target < 0 ? -1 * target : target;

  let multiple = Math.pow(10, precision - 0);
  if (type === "ceil") {
    target = Math.ceil(target * multiple) / multiple;
  } else if (type === "floor") {
    target = Math.floor(target * multiple) / multiple;
  } else {
    target = Math.round(target * multiple) / multiple;
  }

  const target_str = target.toString();
  // 处理小数部分
  let target_int = target_str.includes(".") ? target_str.split(".")[0] : target;
  let target_decimal = target_str.includes(".") ? target_str.split(".")[1] : "";

  if (target_decimal.length < precision) {
    for (let i = 0; i < precision; i++) {
      target_decimal = target_decimal + "0";
      if (target_decimal.length === precision) {
        break;
      }
    }
  }

  return target_s + target_int + (precision > 0 ? "." + target_decimal : "");
};
```
