
## 搭建 gitlab 服务

> 私有的项目管理仓库, 对于任何一个公司来说都是必须的. 所以, 作为一名开发人员, 如何搭建一个 gitlab 服务, 是一个很有必要的技能.

<!--more-->

---

## 安装

> [文档参考](https://about.gitlab.com/install/#ubuntu)

### 1. 安装必要依赖

```
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-eertificates
```

安装 postfix 用来发送通知电子邮件

```
sudo apt-get install -y postfix
```

### 2. 添加 gitlab 包仓库并安装包

```
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
```

安装 gitlab 包并配置 访问地址

```
# EXTERANL_URL 后期可通过文件 /etc/gitlab/gitlab.rb 修改
sudo EXTERNAL_URL="http://localhost:8010" apt-get install gitlab-ee
```

完成以上步骤即可通过访问 EXTERNAL_URL 访问 gitlab.

---

## 安装过程遇到的一些问题

### 1. 安装 gitlab-ee 失败

> error: Unable to locate package gitlab-ee

```
sudo apt-get install gitlab-ee

报错 Unable to locate package gitlab-ee
```

> 解决方法

修改 /etc/apt/sources.list.d/gitlab_gitlab-ee.list

```
deb https://packages.gitlab.com/gitlab/gitlab-ee/ubuntu/ cosmic main
deb-src https://packages.gitlab.com/gitlab/gitlab-ee/ubuntu/ cosmic main
```

改成:

```
deb https://packages.gitlab.com/gitlab/gitlab-ee/ubuntu/ xenial main
deb-src https://packages.gitlab.com/gitlab/gitlab-ee/ubuntu/ xenial main

```

修改后重新安装:

```
sudo apt-get update
sudo apt-get install gitlab-ee
```

---

### 2. 访问 502

```
vim /etc/gitlab/gitlab.rb
```

修改:

```
external_url 'http://localhost:8010'
unicorn['port'] = 8088
postgresql['shared_buffers'] = "256MB"
postgresql['max_connections'] = 200
```

```
# 重新设置配置文件
sudo gitlab-ctl reconfigure
# 重启
gitlab-ctl restart 
```

---

### 3. 修改 clone 地址

```
sudo vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
```

---

## 常用命令

| 命令功能 | 执行命令 |
|-|-|
| 重启配置并启动 gitlab 服务 | sudo gitlab-ctl reconfigure |
| 启动所有 | gitlab	sudo gitlab-ctl start |
| 重新启动GitLab | sudo gitlab-ctl restart |
| 停止所有 | gitlab sudo gitlab-ctl stop |
| 查看服务状态 | sudo gitlab-ctl status |
| 查看Gitlab日志 | sudo gitlab-ctl tail |
| 修改默认的配置文件 | sudo vim /etc/gitlab/gitlab.rb |
| 检查gitlab | gitlab-rake gitlab:check SANITIZE=true --trace |