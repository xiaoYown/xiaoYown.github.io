
### 常用命令

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

### 数据迁移

```sh
# 容器内内执行, 在 data/backups 目录下生成 <datetime>_gitlab_backup.tar
gitlab-rake gitlab:backup:create RAILS_ENV=production

# 将 gitlab_backup.tar 拷贝到新容器的 data/backups 下(需保证 data 目录给过权限)
gitlab-rake gitlab:backup:restore RAILS_ENV=production BACKUP=<datetime>

# 重启服务
gitlab-ctl restart
```
