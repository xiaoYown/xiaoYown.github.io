## git 常用命令记录

> 大部分的开发人员都会使用 git，同时依赖依赖客户端管理工具的也很多(我就是一个). 但某些情况下仍然需要使用命令来协助开发, 在此记录一些 git 命令(主要是帮助自己记录 = =).

<!--more-->

---

### 1. 拉取指定分支到本地

```
git clone -b branch_name folder_name 
```

### 2. 同一分支开发提交 (无冲突)

```
git fetch
git add
git commit -m "message"
git merge --ff
git push
```

### 3. 同一分支开发提交 (有冲突)

```
# 提交代码

git add
git commit -m "message"

# 更新远程代码到本地

git pull --rebase (此时产生冲突)
git add .

# 解决冲突后切回原分支

git rebase --continue

# 追加提交到刚刚没有 merge 的提交中

git commit --amend

# 推送

git push origin
```

### 4. log 相关

```
# 默认
git log

# 查看所有分支的历史
git log --all

# 查看图形化的版本演变历史
git log --all --graph

# 查看当行的简洁历史
git log --oneline

# 查看最近的四条简洁历史
git log --oneline -n4

# 查看所有分支最近4条单行的图形演变历史
git log --oneline -n4 --graph

# 跳转到gitlog的帮助文档网页
git help --web log

```

### 5. pull request 工作流合并

```
# 在 github 上 pull request 或者 gitlab 上 create merge request

# Step 1. Fetch and check out the branch for this merge request

git fetch origin
git checkout -b dev origin/dev

Step 2. Review the changes locally

Step 3. Merge the branch and fix any conflicts that come up

git fetch origin
git checkout master
git merge --no-ff dev

Step 4. Push the result of the merge to GitLab

git push origin master

```

### 6. 仓库相关

```
# existing_folder
git init
git remote add origin <url>
# 修改仓库地址
git remote set-url <new_url>
```

### 其他命令

```
# 查看未暂存改动
git diff

# 查看已暂存改动
git diff --cached

# 检出新分支
git checkout -b

# 删除本地分支
git branch -d branch_name

# 删除远程分支
git push origin --delete btanch_name

# 设置关联的远程分支
git branch --set-upstream-to=origin/<branch> <branch_local>

# 提交合并
git commit --amend
```