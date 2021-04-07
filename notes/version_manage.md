## 版本管理

### 1. 版本规则

<br/>

> 版本变更遵循 SemVer .

| Major 版本增量 | Minor 版本增量 |	Patch 版本增量 |
| - | - | - |
| 突破性变更 |	无突破性变更 | bug 修复 |

<br/>

> 开发期

<br/>

- Alpha(α): 预览版, 或者叫内部测试版；一般不向外部发布, 会有很多Bug；一般只有测试人员使用。

- Beta(β): 测试版, 或者叫公开测试版；这个阶段的版本会一直加入新的功能；在 Alpha版之后推出。
- RC(Release Candidate): 最终测试版本；可能成为最终产品的候选版本, 如果未出现问题则可发布成为正式版本

> 完成期

- Stable: 稳定版；来自预览版本释出使用与改善而修正完成

### 2. commit message
<br />

> commit 提交规范

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

```
type: 代表某次提交的类型, 比如是修复一个bug还是增加一个新的feature.

type类型如下: 

feat[特性]:新增feature 
fix[修复]: 修复bug     
docs[文档]: 仅仅修改了文档，比如README, CHANGELOG, CONTRIBUTE等等
style[格式]: 仅仅修改了空格、格式缩进、都好等等，不改变代码逻辑
refactor[重构]: 代码重构，没有加新功能或者修复bug
perf[优化]: 优化相关，比如提升性能、体验
test[测试]: 测试用例，包括单元测试、集成测试等
chore[工具]: 改变构建流程、或者增加依赖库、工具等
revert[回滚]: 回滚到上一个版本

scope:
scope 说明 commit 影响的范围.
scope依据项目而定, 例如在业务项目中可以依据菜单或者功能模块划分, 如果是组件库开发, 则可以依据组件划分.

subject: 是commit的简短描述, 不能省略.
body: 提交代码的详细描述, 可以省略.
footer: 如果代码的提交是不兼容变更或关闭缺陷, 则Footer必需, 否则可以省略.
```
<br />

```yml
# 若输入有误需要修改, 使用以下指令调整 commit message
git commit --amend
```

### 3. release

*注意: 必须在有 breaking 变更时执行发布指令*

```
npx standard-version: 版本自增(不推荐使用)
npx standard-version -p beta: 发布 beta 版本
npx standard-version -p alpha: 发布 alpha 版本
npx standard-version -r patch: 发布 patch 版本
npx standard-version -r minor: 发布 minor 版本
npx standard-version -r major: 发布 major 版本
npx standard-version -r <version>: 指定版本发布
```

### 4. 开发流程

```
1. 新建开发分支 fix/<code> | feat/<code>
2. 开发功能
3. 使用自定义指令(eg: yarn commit)完成代码提交, 不推荐使用 git commit 直接提交
4. 从公共分支合并提交(cherry-pick/merge)
5. 完成当前迭代功能合并后, 使用对应指令发布版本
6. 推送并打 TAG: git push --follow-tags origin master
```

### 5. 案例

[demo](https://github.com/xiaoYown/changelog-eg)

### 附录
<br />

> 依赖说明

```
commitizen: commit message 规则
commitlint-config-cz: 自定义校验规则
standard-version: 生成 changelog
```
