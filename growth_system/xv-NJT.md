## xv-design

---

### 1. 业务功能概览

- 数据报表/报告
- 表单(no must)

#### 1.1 新建项目

- 树形结构

#### 1.2 报告初始类型

- PC 单页大屏
- PC 多页大屏
- PC 长页(有插件隐藏特性)
- modbile 单页大屏
- modbile 多页大屏
- modbile 长页(有插件隐藏特性)

> 提供尺寸切换(750/1920/...), 全局尺寸自动适配(不提供自定义尺寸)

### 2 功能模块

- chart 报告制作(编辑器/播放器)
- form 表单制作(编辑器/播放器)
- 数据源(静态数据/API/数据库接入)
- 流程图(编辑器/播放器)

---

### 2 Chart - Project

#### 2.1 编辑机制

#### 2.2 播放机制

---

### 3 Form - Project

#### 3.1 编辑机制

#### 3.2 填写机制

- 数据采集阶段
- 采集结束阶段

#### 3.3 与 chart 对接

- 在 chart 编辑器中, 数据源选择 xvd-form

---

### 4 数据源 - Module

#### 4.1 数据注入机制

#### 4.2 数据整理

- 官方聚合插件
- 自定义聚合插件

---

### 5 插件与组件

#### 5.1 插件

- 官方插件
- 开发者插件

#### 5.2 编辑栏配套组件

- ***

### 6 插件

- 编辑(本地脚手架 or 线上低代码)
- 数据兼容处理
- 资源管理
- 插件异步加载方案
- 第三方库版同资源加载方案(考虑多依赖同时使用)

#### 6.1 插件类型

##### 6.1.1 元素插件

###### 1) 插件结构

```
- <name>/<version>
  - application.json(插件描述文件)
  - player.sys.js
  - player.css(not must)
  - settings.sys.js
  - settings.source.css(not must)
  - toolbar.sys.js
  - toolbar.source.css(not must)
  - compatible.js(数据版本兼容处理)
  - application.source.zip(源码存放)
```

###### 2) 插件 hooks(必须固定, 无需非变革性改动尽量不要变更)

1. hooks - 编辑器

- touchBeforeMount
- touchMounted
- touchUpdate (入参为 [props, nextProps];若返回返回 promise, 则在 fulfilled 状态进行数据更新, reject 禁止更新; 若为 boolean, 返回 false 禁止更新)
- touchBeforeDestroy
- touchDestroy
- touchActivated (显示)
- touchDeactivated (隐藏)

2. hooks - 播放器

- touchBeforeMount
- touchMounted
- touchUpdate
- touchBeforeDestroy
- touchDestroy
- touchActivated
- touchDeactivated
- touchAnimationInActive
- touchAnimationInEnd
- touchAnimationOutActive
- touchAnimationOutEnd

3. subscribe - 订阅

- 数据变更订阅(编辑器)
- 数据源更新订阅
- 画布大小变更, resize 订阅

4. 注意

```
以上规则, 为保障兼容性, hooks/subscribe 仅能在基础上更新, 若需要变更, 则为方案重新定制.
方案重置, 则整体系统将需要重新编译以及处理所有插件 源码以及构建包, 此变更需要做大版本更新, 虽然是可兼容性变更.
```

###### 3) 插件相关参数(未定)

```json
{
  "element": {
    "open": true,
    "application": {
      "id": "**",
      "name": "element-name",
      "version": "1.0.0"
    }
  }
}
```

##### 6.1.\* sidebar 插件

##### 6.1.\* toolbar 插件

##### 6.1.\* 数据源驱动 扩展

##### 6.1.\* \*

#### 6.2 插件开发

- 脚手架
- 客户端(CS)

#### 6.3 插件上架流程

1. 开发及本地调试
2. alpha 版本上架, 仅开发者账号可获取到, 可在自身账号进入编辑器进行内测
3. beta 版本上架, 所有用户可所有到并使用
4. stable 版本上架

> alpha/beta 版本可被覆盖以及删除
> stable 版本一经上架, 不可删除以以及覆盖, 有问题可使用下一版本 compatible 机制进行修复
> beta/stable 版本, 若存在数据变更, 需考虑使用 compatible
> 可关闭插件对外启用(不可在插件市场搜索到, 已使用的仍可查看, 但不可编辑)

---

### 7 渲染机制

- 任务机制(未定)

### 8 编辑机制

- 多元素更新同时加入任务队列

#### 8.1 插件使用数据错误

- 数据更新在确认插件使用更新数据正确后, 所有数据更新触发插件任务均采用异步, 执行错误的插件将不会更新数据, 并上报错误, 后台记录; 开发者接收到报错信息, 完成修复后更新, 修复消息推送到发生错误的用户

...

### 9. 版本管理

#### 9.1 model 基础数据版本

#### 9.2 model 扩展数据版本

#### 9.3 数据版本兼容处理

...

### 10 项目基础功能概览

#### 10.1 用户操作埋点

#### 10.2 功能异常埋点

...

### 服务端

v1.0 (摊子太大, 暂不提供过多工功能)

- kong
- 用户体系
- 报告中心
- 播放器
- BS 编辑器仅提供体验, 可通过客户端发布到线上播放器
- 插件市场
- ...

v\*

...

### 体验要求

- 性能/操作流畅度优先
- 任何代码层面有过渡处理, 都需要反馈到用户视觉上
- 任何列表渲染, 均需考虑无数量限制
- ...

...
