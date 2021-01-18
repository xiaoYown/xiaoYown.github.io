[参考1](https://juejin.cn/post/6844904025868271629)
[参考2](https://juejin.cn/post/6844903831893966856)
[参考3](https://juejin.cn/post/6844903847924596743)

- commitizen
- cz-conventional-changelog
- conventional-changelog-cli

---

### 安装

npm i -D commitizen cz-conventional-changelog

```json
### package.json

{

  "config":{
    "commitizen":{
      "path":"node_modules/cz-conventional-changelog"
    }
  },
  "script": {
    "commit": "git-cz"
  }
}
```

<!-- ### commitlint校验

npm i -D @commitlint/config-conventional @commitlint/cli -->

---

### 自定义提交规范(不建议使用)

npm i -D commitlint-config-cz  cz-customizable

```json
### package.json

{

  "config":{
    "commitizen":{
      "path": "node_modules/cz-customizable"
    }
  },
  "script": {
    "commit": "./node_modules/cz-customizable/standalone.js"
  }
}
```

```js
// .cz-config.js
module.exports = {
  types: [
    {
      value: "init",
      name: "init: 初始提交"
    },
    {
      value: "feat",
      name: "feat: 新功能(feature)"
    },
    {
      value: "fix",
      name: "fix: 修补 bug"
    },
    {
      value: "ui",
      name: "ui: 更新UI"
    },
    {
      value: "refactor",
      name: "refactor: 重构(即不是新增功能，也不是修改 bug 的代码变动)"
    },
    {
      value: "release",
      name: "release: 发布"
    },
    {
      value: "deploy",
      name: "deploy: 部署"
    },
    {
      value: "docs",
      name: "docs: 修改文档"
    },
    {
      value: "test",
      name: "test: 增删测试"
    },
    {
      value: "chore",
      name: "chore: 构建过程或辅助工具的变动"
    },
    {
      value: "style",
      name: "style: 格式(不影响代码运行的变动)"
    },
    {
      value: "revert",
      name: "revert: 回滚代码"
    },
    {
      value: "add",
      name: "add: 添加依赖"
    },
    {
      value: "minus",
      name: "minus: 版本回退"
    },
    {
      value: "del",
      name: "del: 删除代码/文件"
    },
  ],
  scopes: [],
  messages: {
    type: "选择更改类型:\n",
    scope: "更改的范围:\n",
    // 如果allowcustomscopes为true，则使用
    // customScope: 'Denote the SCOPE of this change:',
    subject: "简短描述:\n",
    body: '详细描述. 使用"|"换行:\n',
    breaking: "Breaking Changes列表:\n",
    footer: "关闭的issues列表. E.g.: #31, #34:\n",
    confirmCommit: "确认提交?",
  },
  allowCustomScopes: true,
  allowBreakingChanges: ["feat", "fix"],
};
```

---

### semver

遵循 semver。

下面是一个表格，明确地将变化的类型映射到它们对应的 semver 类别 (例如Major，Minor，Patch)。

| Major 版本增量 |	Minor 版本增量	| Patch 版本增量|
|-|-|-|
| 突破性变更 | 无突破性变更	| 修复 |

---

### [changelog 生成](https://www.npmjs.com/package/standard-version)

npm i standard-version -D

```json
{
  "scripts": {
    "release": "npx standard-version",
    "release:beta": "npx standard-version -p beta",
    "release:alpha": "npx standard-version -p alpha",
    "release:patch": "npx standard-version -r patch",
    "release:minor": "npx standard-version -r minor",
    "release:major": "npx standard-version -r major",
    "release:version": "npx standard-version -r"
  }
}
```