[参考(https://mp.weixin.qq.com/s/J6xHq9g91_TLgQLE6P_Teg)

### type

> 类型别名用来给一个类型起个新名字，使用 type 创建类型别名，类型别名不仅可以用来表示基本类型，还可以用来表示对象类型、联合类型、元组和交集。

```ts
type userName = string; // 基本类型
type userId = string | number; // 联合类型
type arr = number[];

// 对象类型
type Person = {
  id: userId; // 可以使用定义类型
  name: userName;
  age: number;
  gender: string;
  isWebDev: boolean;
};
// 范型
type Tree<T> = { value: T };

const user: Person = {
  id: "901",
  name: "椿",
  age: 22,
  gender: "女",
  isWebDev: false,
};

const numbers: arr = [1, 8, 9];
```

### interface

> 接口是命名数据结构（例如对象）的另一种方式；与 type 不同，interface 仅限于描述对象类型。
> 接口的声明语法也不同于类型别名的声明语法。让我们将上面的类型别名 Person 重写为接口声明：

```ts
interface Person {
  id: userId;
  name: userName;
  age: number;
  gender: string;
  isWebDev: boolean;
}
```

### 相似之处

#### 都可以描述 Object 和 Function

```ts
// Type
type Point = {
  x: number;
  y: number;
};

type SetPoint = (x: number, y: number) => void;

// Interface
interface Point {
  x: number;
  y: number;
}

interface SetPoint {
  (x: number, y: number): void;
}
```

#### 二者都可以被继承

> 另一个值得注意的是，接口和类型别名并不互斥。类型别名可以继承接口，反之亦然。只是在实现形式上，稍微有些差别。

```ts
// interface 继承 interface
interface Person{
    name:string
}

interface Student extends Person { stuNo: number }

// interface 继承 type
type Person{
    name:string
}

interface Student extends Person { stuNo: number }

// type 继承 type
type Person{
    name:string
}

type Student = Person & { stuNo: number }

// type 继承 interface
interface Person{
    name:string
}

type Student = Person & { stuNo: number }
```

#### 实现 implements

> 类可以实现 interface 以及 type(除联合类型外)

```ts
interface ICat {
  setName(name: string): void;
}

class Cat implements ICat {
  setName(name: string): void {
    // ...
  }
}

// type
type ICat = {
  setName(name: string): void;
};

class Cat implements ICat {
  setName(name: string): void {
    // todo
  }
}
```

> 上面提到了特殊情况，类无法实现联合类型, 是什么意思呢？

```ts
type Person = { name: string } | { setName(name: string): void };

// 无法对联合类型Person进行实现
// error: A class can only implement an object type or intersection of object types with statically known members.
class Student implements Person {
  name = "张三";
  setName(name: string): void {
    // todo
  }
}
```

### 二者区别

#### 1. 定义基本类型别名 - type

type 可以定义基本类型别名, 但是 interface 无法定义,如:

```ts
type userName = string;
type stuNo = number;
// ...
```

#### 2. 声明联合类型 - type

type 可以声明联合类型, 例如:

```ts
type Student = { stuNo: number } | { classId: number };
```

#### 3. 声明元组 - type

```ts
type Data = [number, string];
```

#### 4. 声明合并 - interface

```ts
interface Person {
  name: string;
}
interface Person {
  age: number;
}

let user: Person = {
  name: "Tolu",
  age: 0,
};
```

```ts
type Person { name: string };

// Error: 标识符“Person”重复。ts(2300)
type Person { age: number }
```

#### 5. 索引签名问题

> Type 'xxx' is not assignable to type 'yyy'
> Index signature is missing in type 'xxx'.

```ts
interface propType {
  [key: string]: string;
}

let props: propType;

type dataType = {
  title: string;
};
interface dataType1 {
  title: string;
}
const data: dataType = { title: "订单页面" };
const data1: dataType1 = { title: "订单页面" };
props = data;
// Error:类型“dataType1”不可分配给类型“propType”; 类型“dataType1”中缺少索引签名
props = data1;
```
