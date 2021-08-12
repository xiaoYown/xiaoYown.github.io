### 类型

1. 布尔 - boolean

2. 数字 - number

3. 字符串 - string

4. 数组 - number[]|Array<number>

5. 元组, 元组类型允许表示一个已知元素数量和类型的数组, 各元素的类型不必相同(Tuple)
```ts
let x: [string, number]
```
> (当访问一个已知索引的元素, 会得到正确的类型. 当访问一个越界的元素, 会使用联合类型替代)

6. 枚举 - enum Color {Red = 1, Green, Blue}

7. any - 不清楚的变量类型

8. void - void类型像是与any类型相反, 它表示没有任何类型. 
```ts
// 某种程度上来说, void类型像是与any类型相反, 它表示没有任何类型. 当一个函数没有返回值时, 你通常会见到其返回值类型是 void:
function warnUser(): void {
  console.log("This is my warning message");
}
// 声明一个void类型的变量没有什么大用, 因为你只能为它赋予undefined和null:
let unusable: void = undefined;
```

9. Null 和 Undefined
```
TypeScript里，undefined和null两者各自有自己的类型分别叫做undefined和null. 和 void相似，它们的本身的类型用处不是很大
```

10. Never
```
never类型表示的是那些永不存在的值的类型.
```

11. Object
```ts
// object表示非原始类型，也就是除number，string，boolean，symbol，null或undefined之外的类型
declare function create(o: object | null): void;

create({ prop: 0 }); // OK
create(null); // OK

create(42); // Error
create("string"); // Error
create(false); // Error
create(undefined); // Error
```

### 类型断言
通过类型断言这种方式可以告诉编译器，"相信我，我知道自己在干什么".
```ts
// 类型断言有两种形式. 其一是"尖括号"语法:
let someValue: any = "this is a string";
let strLength: number = (<string>someValue).length;
// 另一个为as语法:
let someValue: any = "this is a string";
let strLength: number = (someValue as string).length;
```

### type(类型别名)

1. 类型别名会给一个类型起个新名字。 类型别名有时和接口很像，但是可以作用于原始值，联合类型，元组以及其它任何你需要手写的类型。

2. 起别名不会新建一个类型 - 它创建了一个新 名字来引用那个类型。 给原始类型起别名通常没什么用，尽管可以做为文档的一种形式使用。

3. 类型别名也可以是泛型

### interface

#### 可选属性 - ?
#### 只读属性 - readonly

```ts
interface SquareConfig {
  color?: string;
  readonly width?: number;
  // 字符串索引签名
  [propName: string]: any;
  // TypeScript支持两种索引签名：字符串和数字
  [x: number]: string;
  [x: string]: number;
}
```

#### 函数类型 - 描述函数类型
```ts
interface SearchFunc {
  (source: string, subString: string): boolean;
}
//
let mySearch: SearchFunc;
mySearch = function(src: string, sub: string): boolean {
  let result = src.search(sub);
  return result > -1;
}
//
let mySearch: SearchFunc;
mySearch = function(src, sub) {
    let result = src.search(sub);
    return result > -1;
}
```

#### 类类型

##### 实现接口

接口描述了类的公共部分，而不是公共和私有两部分。 它不会帮你检查类是否具有某些私有成员。

#### 继承接口

一个接口可以继承多个接口，创建出多个接口的合成接口

#### 混合类型

```ts
// 一个对象可以同时做为函数和对象使用，并带有额外的属性
interface Counter {
    (start: number): string;
    interval: number;
    reset(): void;
}

function getCounter(): Counter {
    let counter = <Counter>function (start: number) { };
    counter.interval = 123;
    counter.reset = function () { };
    return counter;
}

let c = getCounter();
c(10);
c.reset();
c.interval = 5.0;
```

#### 接口继承类

```ts
//当你有一个庞大的继承结构时这很有用，但要指出的是你的代码只在子类拥有特定属性时起作用。 这个子类除了继承至基类外与基类没有任何关系

class Control {
  private state: any;
}

interface SelectableControl extends Control {
  select(): void;
}

class Button extends Control implements SelectableControl {
  select() { }
}

class TextBox extends Control {
  select() { }
}

// 错误：“Image”类型缺少“state”属性。
class Image implements SelectableControl {
  select() { }
}

class Location {

}
```

### extends

- 接口继承
- 类继承
- 泛型约束

### Record

```ts
// 以 typeof 格式快速创建一个类型，此类型包含一组指定的属性且都是必填
type Coord = Record<'x' | 'y', number>;
// 等同于
type Coord = {
	x: number;
	y: number;
}

```

### Pick

```ts
// 从类型定义的属性中，选取指定一组属性，返回一个新的类型定义
type Coord = Record<'x' | 'y', number>;
type CoordX = Pick<Coord, 'x'>;

// 等用于
type CoordX = {
	x: number;
}
```

### Omit

```ts
type Omit<T, K> = Pick<T, Exclude<keyof T, K>>
```

### Partial

```ts
// 将类型定义的所有属性都修改为可选
interface CoordInter {
  x: number;
  y: number;
} 
type Coord = Partial<CoordInter>
let coord: Coord = { x: 10 }
```

### 泛型

T - 帮助我们捕获用户传入的类型

```ts
function identity<T>(arg: T): T {
  return arg;
}
// 明确指定类型
let output = identity<string>("myString");
// 类型推论
let output = identity("myString");

// 数组
function loggingIdentity<T>(arg: T[]): T[] {
  console.log(arg.length);  // Array has a .length, so no more error
  return arg;
}

// 函数声明
function identity<T>(arg: T): T {
  return arg;
}
let myIdentity: <T>(arg: T) => T = identity;

// 泛型接口
interface GenericIdentityFn {
  <T>(arg: T): T;
}
function identity<T>(arg: T): T {
  return arg;
}
let myIdentity: GenericIdentityFn = identity;

// 泛型类
// ...

// 泛型约束
interface Lengthwise {
  length: number;
}
function loggingIdentity<T extends Lengthwise>(arg: T): T {
  console.log(arg.length);  // Now we know it has a .length property, so no more error
  return arg;
}
```