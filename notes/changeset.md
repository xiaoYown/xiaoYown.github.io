pnpm install @changesets/cli && npx changeset init

### normal release

npx changeset

npx changeset version

npx changeset publish

---

### prerelease

npx changeset pre enter tag(alpha|beta|rc)

npx changeset

npx changeset version

npx changeset publish

### other

npx changeset pre exit

### 提交流程

1. 修改完成后 pnpm bump (填写本次提交日志信息)
2. git add .
3. pnpm commit

### 发版流程

1. pnpm bump:v
2. git add .
3. pnpm commit(更新 changelogs)
