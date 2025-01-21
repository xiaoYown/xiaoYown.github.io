### docker 日常使用

#### 操作

```yml
# 启动
sudo systemctl start docker
# 开启 Docker 开机自启动
$ sudo systemctl enable docker
# 关闭 Docker 开机自启动
$ sudo systemctl disable docker
```

#### 镜像指令

```yml
# 去下载镜像，先从本地找，没有去镜像，最后没有去 hub，标签不写默认为 lastest
$ docker pull [镜像名]:[标签Tag]

# 列出本机的所有 image 文件，-a 显示本地所有镜像（包括中间镜像），-q 只显示镜像ID，--digests 显示镜像的摘要信息
$ docker image ls
$ docker images

# 删除 image 文件, -f 强制删除镜像
$ docker rmi [镜像名][:标签Tag]
$ docker rmi [镜像名1][:标签Tag] [镜像名2][:标签Tag]    # 删多个
$ docker rmi $(docker ps -a -q)    # 删全部，后面是子命令

# 查询镜像名称，--no-trunc 显示完整的镜像描述，--filter=stars=30 列出star不少于指定值的镜像，--filter=is-automated=true 列出自动构建类型的镜像
$ docker search [关键字]

# 下载镜像，标签 tag 不写默认为 lastest，也可以自己加比如 :3.2.0
$ docker pull [镜像名][:标签Tag]
```

#### 容器指令

```yml
# 列出本机正在运行的容器，-a 列出本机所有容器包括终止运行的容器，-q 静默模式只显示容器编号，-l 显示最近创建的容器
$ docker container ls     # 等价于下面这个命令
$ docker ps

# 新建并启动容器
$ docker run [option] [容器名]

# 启动容器
$ docker start [容器ID]/[容器Names]

# 重启容器
$ docker restart [容器ID]/[容器Names]

# 终止容器运行
$ docker kill [容器ID]  # 强行终止，相当于向容器里面的主进程发出 SIGKILL 信号，那些正在进行中的操作会全部丢失
$ docker kill $(docker ps -a -q) # 强行终止所有容器
$ docker stop [容器ID]  # 从容终止，相当于向容器里面的主进程发出 SIGTERM 信号，然后过一段时间再发出 SIGKILL 信号
$ docker stop $(docker ps -a -q) # 终止所有容器

# 终止运行的容器文件，依然会占据硬盘空间，可以使用 docker container rm 命令删除，-f 强制删除可以删除正在运行的容器
$ docker rm [容器ID]
$ docker rm `docker ps -aq`    # 删除所有已经停止的容器，因为没停止的rm删不了需要加-f

# 查看容器的输出，-t加入时间戳，-f跟随最新日志打印，--tail数字显示最后多少条，如果docker run时，没有使用-it，就要用这个命令查看输出
$ docker logs [容器ID]

# 查看容器进程信息
$ docker top [容器ID]/[容器Names]
$ docker port [容器ID]/[容器Names]

# 退出容器
$ exit           # 容器退出
ctrl + p + q     # 容器退出，快捷键

# 进入容器
$ docker attach [容器ID]      # 退出容器时会让容器停止，本机的输入直接输到容器中
$ docker exec -it [容器ID]    # 退出容器时不会让容器停止，在已运行的容器中执行命令，不创建和启动新的容器

# 设置容器在docker启动时自动启动
$ docker container update --restart=always [容器名字]
```

> nginx

```yml
# 创建容器
docker run -d --name nginx -p 80:80 --privileged=true nginx
# 复制配置文件以及数据目录
transformers-pytorch-cpu_redis_1 nginx:/etc/nginx ./
docker cp nginx:/usr/share/nginx/html ./
docker cp nginx:/var/log/nginx ./nginx_logs
# 移除容器
docker rm -f <container_name>
# 使用 docker-compose 启动容器
docker-compose up -d

# docker-compose
version: '3'
services:
  mysql:
    image: nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx:/etc/nginx
      - ./nginx_logs:/var/log/nginx
      - ./html:/usr/share/nginx/html
    networks:
      - backend
    restart: always
    container_name: nginx_xv
networks:
  frontend:
  backend:
```

> mysql

```yml
# 创建容器
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=888888 --name mysql_xv mysql

# 复制配置文件以及数据目录
docker cp mysql_xv:/var/lib/mysql ./mysql/data
docker cp mysql_xv:/etc/mysql/conf.d ./mysql/mysql.d

# 更新密码
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '888888';

# 移除容器
docker rm -f <container_name>

# 使用 docker-compose 启动容器
docker-compose up -d

# docker-compose
version: '3'
services:
  mysql:
    image: mysql
    ports:
      - "3306:3306"
    volumes:
      - ./data:/var/lib/mysql
      - ./mysql.d:/etc/mysql/conf.d
    environment:
      MYSQL_ROOT_PASSWORD: 888888
    networks:
      - backend
    restart: always
    container_name: mysql_xv
networks:
  frontend:
  backend:
```

#### 进入 docker 目录

```
执行这段代码进入 vm
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty

然后你就可以进入docker的目录了
cd /var/lib/docker
```

#### 清除缓存

```
docker system prune --volumes
```

> node

```yml
# 获取 slim 镜像
docker pull node:14.15.1-slim
# 创建容器
docker run -d -p 3000:3000 --name easy_format_xv node:14.15.1-slim node -e "require('http').createServer((req, res) => res.end('Hello World')).listen(3030)"
```

### 创建本地仓库

```docker-compose.yml
version: "3"
services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    volumes:
      - ./data:/var/lib/registry
```

允许 http
```daemon.json
{
  "insecure-registries": ["192.168.50.41:5000"]
}
```

1. 标记仓库镜像地址:
docker tag verdaccio/verdaccio 192.168.50.41:5000/verdaccio/verdaccio:latest

2. 推送仓库
docker push 192.168.50.41:5000/verdaccio/verdaccio:latest

3. 拉去镜像
docker pull 192.168.50.41:5000/verdaccio/verdaccio:latest
