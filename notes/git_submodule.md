### 管理子模块

#### 1. 添加子模块

git clone https://github.com/imtianx/MainProject.git
cd MainProject/
git submodule add -b <branch> https://github.com/imtianx/liba.git <folder>

#### 2. 更新子模块

git submodule update --remote <submodule>

#### 3. 删除子模块

vim .gitmodules

#### 4. 克隆含子模块的仓库

git clone --recursive -b <branch> https://github.com/imtianx/MainProject.git <folder>

#### 5. 强制更新所有子模块

git submodule update --recursive


### 构建流程:

#### 1. 直接 clone 后构建

git clone --recursive -b <branch> https://github.com/imtianx/MainProject.git <folder>

获取所有最新子模块, 可直接构建

#### 2. 子模块 更新/构建

> 更新

```yml
# 更新子模块
cd <sub_module>
git submodule update --remote <submodule>

# 主模块提交
cd ..
git add .
git commit -m "..."
git push

```

> 获取更新

```yml
# 主模块下
git pull
git submodule update --recursive
```