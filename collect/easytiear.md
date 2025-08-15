[参考](https://doc.oee.icu:60009/web/#/625560517/103293292)

### EasyTier（ET）安装与配置简要说明

**背景说明**  
EasyTier 用 Rust 开发，直接编译为二进制文件，在Linux系统上无需繁琐依赖，上传即可运行。客户端和服务端共用同一套程序，只要开放端口即可作为服务端，否则为客户端。

___

#### 1\. 下载ET二进制文件

```bash
mkdir -p /etc/et && cd /etc/et
wget https://github.com/EasyTier/EasyTier/releases/download/v2.3.2/easytier-linux-x86_64-v2.3.2.zip
```

_说明：_  
建议用root用户执行。你也可以用浏览器提前[下载](https://github.com/EasyTier/EasyTier/releases "下载")，直接拖到`/etc/et/`目录。

___

#### 2\. 解压二进制文件

```bash
unzip easytier-linux-x86_64-v2.3.2.zip
cp easytier-linux-x86_64/* ./
chmod 700 ./*
```

_说明：_  
将解压出来的可执行文件复制到当前目录，并赋予执行权限。

___

#### 3\. 配置文件准备

```makefile
echo 'instance_name = "default"
instance_id = "5e525177-b2da-4be5-add2-cc80db184fa3"
ipv4 = "10.0.0.1"
# 自动分配IP打开
dhcp = true
# 自定义 使用 60006 60007 端口作为监听发现服务 默认监听IPv4/IPv6
listeners = [
    "tcp://0.0.0.0:60006",
    "udp://0.0.0.0:60006",
    "udp://[::]:60006",
    "tcp://[::]:60006",
]
exit_nodes = []
rpc_portal = "127.0.0.1:15889"

# xxxx 是自定义网络和密码参数，牢记，用于组网
[network_identity]
network_name = "xxxx"
network_secret = "xxxx"

# tcp://c.oee.icu:60006 是自定义要连的其他节点
[[peer]]
uri = "tcp://c.oee.icu:60006"

[flags]
default_protocol = "tcp"
dev_name = ""
enable_encryption = true
enable_ipv6 = true
mtu = 1380
latency_first = true
enable_exit_node = false
no_tun = false
use_smoltcp = false
foreign_network_whitelist = "*"
disable_p2p = false
relay_all_peer_rpc = false' > /etc/et/config.ymal && chmod 700 /etc/et/config.ymal
```

_说明：_  
请根据实际需要将上述命令中的 `xxxx` 自定义为你的组网名和密钥，同时复制粘贴时要确保参数内容完整。  
要一字不漏的复制完整后再执行（自动创建文件）。  
也可以手动创建文件，然后复制’内容’到文件。

___

#### 4\. 创建ET服务文件

```makefile
echo '[Unit]
Description=et
[Service]
ExecStart=/etc/et/easytier-core -c /etc/et/config.ymal
Restart=always
User=root
Group=root
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/et.service && chmod 700 /etc/systemd/system/et.service
```

_说明：_  
要一字不漏的复制完整后再执行（会自动创建文件）。

___

#### 5\. 启动ET服务

```sql
systemctl daemon-reload
systemctl start et.service
systemctl restart et.service
```

_说明：_  
每次更改了配置服务文件都需要先执行`systemctl daemon-reload`，否则启动新配置不生效。

___

#### 6\. 查看服务运行状态

```css
systemctl status et.service
systemctl stop et.service
```

_说明：_  
`systemctl status et.service` 命令用于查看ET状态  
`systemctl stop et.service`命令用于停止服务

___

#### 7\. 防火墙设置

```
ufw allow 60006
ufw allow 60007
```

_说明：_  
如使用的是其它防火墙，等效放行相应端口即可。

___

#### 8\. 设置开机自动启动

```bash
systemctl enable et.service
```

___

#### 9\. 取消开机启动

```bash
systemctl disable et.service
```

___

#### 10\. 卸载与清理

```bash
systemctl stop et.service
rm -rf /etc/et/
rm -rf /etc/systemd/system/et.service
```

___

### 重要小贴士

-   **所有命令务必一字不漏复制，否则可能导致服务启动失败或配置丢失。**
-   配置文件内的 `xxxx` 要换成你自定义的组网名和密钥，全网唯一且记牢。
-   “监听端口”决定是服务端还是客户端——只要开放端口就是服务端，否则就是客户端。