# Headscale 自托管网络部署指南

## 概述

Headscale 是 Tailscale 的开源替代方案，基于 WireGuard 协议，提供完全自托管的网格网络解决方案。

## 架构说明

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Headscale 服务器  │    │    客户端设备 A     │    │    客户端设备 B     │
│  (38.47.227.223)   │◄──►│   (内网设备)       │◄──►│   (内网设备)       │
│                     │    │                     │    │                     │
│ - 控制平面          │    │ - Tailscale 客户端 │    │ - Tailscale 客户端 │
│ - 用户管理          │    │ - 自动连接         │    │ - 自动连接         │
│ - 设备认证          │    │                     │    │                     │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

### 节点角色

- **Headscale 服务器**: 控制节点，管理用户、设备认证和网络策略
- **客户端设备**: 运行 Tailscale 客户端，连接到 Headscale 服务器

## 部署步骤

### 第一步: 部署 Headscale 服务器

在公网服务器 (38.47.227.223) 上执行：

#### 1. 安装 Headscale

```bash
# 下载最新版本 (请先查看 https://github.com/juanfont/headscale/releases 获取最新版本号)
HEADSCALE_VERSION="0.26.1"  # 替换为最新版本号
wget https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_amd64

# 安装到系统路径
sudo mv headscale_${HEADSCALE_VERSION}_linux_amd64 /usr/local/bin/headscale
sudo chmod +x /usr/local/bin/headscale

# 创建配置目录
sudo mkdir -p /etc/headscale
sudo mkdir -p /var/lib/headscale
```

#### 2. 创建配置文件

```bash
sudo tee /etc/headscale/config.yaml > /dev/null << 'EOF'
server_url: http://38.47.227.223:8080
listen_addr: 0.0.0.0:8080
metrics_listen_addr: 127.0.0.1:9090

private_key_path: /var/lib/headscale/private.key
noise:
  private_key_path: /var/lib/headscale/noise_private.key

prefixes:
  v4: 100.64.0.0/10
  v6: fd7a:115c:a1e0::/48

derp:
  server:
    enabled: true
    region_id: 999
    region_code: "custom"
    region_name: "Custom DERP"
    stun_listen_addr: "0.0.0.0:3478"
    http_listen_addr: "0.0.0.0:8080"  # 重要：统一使用 8080 端口避免端口冲突
    private_key_path: /var/lib/headscale/derp_server.key
  urls: []  # 不使用官方 DERP 服务器
  auto_update_enabled: false

disable_check_updates: false
ephemeral_node_inactivity_timeout: 30m
database:
  type: sqlite3
  sqlite:
    path: /var/lib/headscale/db.sqlite

acme_url: ""
acme_email: ""
tls_cert_path: ""
tls_key_path: ""

log:
  level: info
  format: text

dns:
  override_local_dns: true
  nameservers:
    global:
      - 1.1.1.1
      - 8.8.8.8
  search_domains: []
  magic_dns: true
  base_domain: headscale.local
EOF
```

#### 3. 创建 systemd 服务

```bash
sudo tee /etc/systemd/system/headscale.service > /dev/null << 'EOF'
[Unit]
Description=headscale controller
After=syslog.target
After=network.target

[Service]
Type=simple
User=headscale
Group=headscale
ExecStart=/usr/local/bin/headscale serve
Restart=always
RestartSec=5

# Optional security enhancements
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/headscale /var/run/headscale
AmbientCapabilities=CAP_NET_BIND_SERVICE
RuntimeDirectory=headscale

[Install]
WantedBy=multi-user.target
EOF
```

#### 4. 创建用户和启动服务

```bash
# 创建专用用户
sudo useradd --create-home --home-dir /var/lib/headscale --system --shell /usr/sbin/nologin headscale

# 设置权限
sudo chown -R headscale:headscale /var/lib/headscale /etc/headscale

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable headscale
sudo systemctl start headscale

# 检查状态
sudo systemctl status headscale
```

#### 5. 配置防火墙

```bash
# Ubuntu/Debian
sudo ufw allow 8080/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### 第二步: 管理用户和设备

#### 1. 创建用户组

```bash
# 创建用户组（类似于 Tailscale 的 tailnet）
sudo headscale users create dev-team
sudo headscale users create production

# 查看用户列表
sudo headscale users list
```

#### 2. 生成预认证密钥

```bash
# 为 dev-team 生成一次性密钥（先查看用户 ID）
sudo headscale users list
# 使用实际的用户 ID（例如 1）
sudo headscale preauthkeys create --user 1 --expiration 24h

# 生成可重复使用的密钥
sudo headscale preauthkeys create --user 1 --expiration 720h --reusable

# 查看所有密钥
sudo headscale preauthkeys -u 1 list
```

### 第三步: 配置客户端设备

在每个客户端设备（设备 A 和设备 B）上执行：

#### 1. 安装 Tailscale 客户端

```bash
# Ubuntu/Debian
curl -fsSL https://tailscale.com/install.sh | sh

# CentOS/RHEL
curl -fsSL https://tailscale.com/install.sh | sh

# macOS
brew install tailscale
# 启动 Tailscale 服务
sudo tailscaled install-system-daemon

# Windows
# 下载并安装 Tailscale Windows 客户端
```

#### 2. 连接到 Headscale 服务器

```bash
# 使用预认证密钥连接
sudo tailscale up --login-server=http://38.47.227.223:8080 --authkey=<预认证密钥>

# 或者手动认证（需要在服务器端手动批准）
sudo tailscale up --login-server=http://38.47.227.223:8080
```

#### 3. 验证连接

```bash
# 查看设备状态
tailscale status

# 查看分配的 IP
tailscale ip

# 测试连接其他设备
tailscale ping <其他设备名称或IP>
```

## 性能优化指南

### 传输速度慢的解决方案

#### 问题诊断

首先在两台在线机器上检查连接状态：

```bash
# 检查网络连接详情
tailscale netcheck

# 查看节点连接状态和延迟
tailscale status

# 测试节点间连接
tailscale ping 100.64.0.1  # 从 xiaoyown 到 Mini-XY-16
tailscale ping 100.64.0.6  # 从 Mini-XY-16 到 xiaoyown
```

#### 解决方案 1: 验证自建 DERP 服务器

**注意**: 如果按照前面的部署步骤操作，DERP 已经正确配置。这里是验证步骤：

```bash
# 验证 DERP 配置
grep -A 8 "derp:" /etc/headscale/config.yaml

# 验证端口监听
sudo netstat -tlnp | grep 8080  # HTTP 和 DERP
sudo netstat -ulnp | grep 3478  # STUN

# 测试 DERP 端点
curl http://localhost:8080/derp  # 应该返回 "DERP requires connection upgrade"
```

如果配置有问题，参考「故障排除」章节的 DERP 配置修复步骤。

#### 解决方案 2: 高级性能优化（可选）

如果需要进一步优化，可以调整这些配置：

```yaml
# 在 /etc/headscale/config.yaml 中添加性能优化
database:
  type: sqlite3
  sqlite:
    path: /var/lib/headscale/db.sqlite
    # 性能优化
    pragma:
      journal_mode: WAL
      synchronous: NORMAL

# 更频繁的节点检查
ephemeral_node_inactivity_timeout: 10m

# DNS 优化（中国大陆用户）
dns:
  nameservers:
    global:
      - 223.5.5.5    # 阿里 DNS
      - 119.29.29.29 # 腾讯 DNS
      - 1.1.1.1
```

#### 解决方案 3: 客户端重连（问题诊断）

```bash
# 如果连接有问题，尝试重新连接
sudo tailscale down
sudo tailscale up --login-server=http://38.47.227.223:8080

# 查看详细网络信息
tailscale netcheck --verbose
tailscale status --json | jq '.Peer[]'  # 查看对等节点详情
```

### 预期效果

正确配置后，你应该看到：
- `tailscale status` 显示节点为 `direct` 连接而不是 `relay`
- ping 延迟 < 50ms (局域网) 或 < 100ms (广域网)
- 文件传输速度接近网络带宽上限

### 性能监控脚本（可选）

可以创建一个监控脚本来定期检查网络状态：

```bash
# 创建监控脚本
sudo tee /usr/local/bin/headscale-check.sh > /dev/null << 'EOF'
#!/bin/bash
echo "=== Headscale 状态检查 $(date) ==="
sudo headscale nodes list
echo -e "\n=== 网络检查 ==="
tailscale netcheck
echo -e "\n=== 连接状态 ==="
tailscale status
EOF

# 设置权限
sudo chmod +x /usr/local/bin/headscale-check.sh

# 运行检查
/usr/local/bin/headscale-check.sh
```

## 服务器端管理命令

### 设备管理

```bash
# 查看所有设备
sudo headscale nodes list

# 查看特定用户的设备
sudo headscale nodes list --user dev-team

# 删除设备
sudo headscale nodes delete <node-id>

# 移动设备到其他用户组
sudo headscale nodes move <node-id> <new-user>

# 检查 DERP 服务器日志
sudo journalctl -u headscale -n 20 --no-pager | grep -i derp
```

### 路由管理

```bash
# 查看路由
sudo headscale routes list

# 启用子网路由
sudo headscale routes enable <route-id>

# 禁用路由
sudo headscale routes disable <route-id>
```

### 用户管理

```bash
# 重命名用户
sudo headscale users rename <old-name> <new-name>

# 删除用户（需要先删除用户下的所有设备）
sudo headscale users delete <user-name>
```

## 客户端常用命令

```bash
# 查看连接状态
tailscale status

# 查看网络信息
tailscale netcheck

# 启用/禁用子网路由广播
sudo tailscale up --advertise-routes=192.168.1.0/24

# 启用/禁用退出节点
sudo tailscale up --advertise-exit-node

# 设置退出节点
sudo tailscale up --exit-node=<exit-node-ip>

# 断开连接
sudo tailscale down

# 查看日志
sudo tailscale bugreport
```

## 故障排除

### 🚨 重要：DERP 服务器配置问题

**问题现象**：客户端报告 "Tailscale could not connect to the 'Custom DERP' relay server" 或者尝试使用 HTTPS 连接 HTTP 服务器。

**根本原因**：`http_listen_addr` 配置不正确，导致端口冲突或协议不匹配。

**解决步骤**：

#### 1. 检查当前 DERP 配置

```bash
# 检查配置文件中的 DERP 设置
grep -A 10 "derp:" /etc/headscale/config.yaml

# 检查端口监听状态
sudo netstat -tlnp | grep 8080  # 检查 TCP 8080
sudo netstat -ulnp | grep 3478  # 检查 UDP 3478
```

#### 2. 修复 DERP 配置

```bash
# 备份配置文件
sudo cp /etc/headscale/config.yaml /etc/headscale/config.yaml.backup

# 修复 http_listen_addr 配置（关键！）
sudo sed -i 's/http_listen_addr: "0.0.0.0:3479"/http_listen_addr: "0.0.0.0:8080"/' /etc/headscale/config.yaml

# 或手动编辑确保配置正确
sudo nano /etc/headscale/config.yaml
```

确保 DERP 配置如下：
```yaml
derp:
  server:
    enabled: true
    region_id: 999
    region_code: "custom"
    region_name: "Custom DERP"
    stun_listen_addr: "0.0.0.0:3478"
    http_listen_addr: "0.0.0.0:8080"  # 🔑 必须与主服务端口一致！
    private_key_path: /var/lib/headscale/derp_server.key
  urls: []
  auto_update_enabled: false
```

#### 3. 重启服务并验证

```bash
# 重启 headscale
sudo systemctl restart headscale

# 检查服务状态和日志
sudo systemctl status headscale
sudo journalctl -u headscale --since "2 minutes ago" | grep -i derp

# 验证端口监听
sudo netstat -tlnp | grep 8080
sudo netstat -ulnp | grep 3478

# 测试 DERP 端点
curl http://localhost:8080/derp  # 应该返回 "DERP requires connection upgrade"
```

#### 4. 客户端协议不匹配问题

**问题现象**：客户端尝试 HTTPS 连接但服务器只提供 HTTP，报错如：
```
register request: Post "https://38.47.227.223:8080/machine/register": connection attempts aborted
```

**解决方案**：完全清理客户端状态

```bash
# macOS 客户端
tailscale down
sudo rm -rf /Library/Tailscale/tailscaled.state
sudo launchctl kickstart -k system/com.tailscale.tailscaled
sleep 5
tailscale up --login-server=http://38.47.227.223:8080 --authkey=<密钥>

# Linux 客户端
sudo tailscale down
sudo rm -rf /var/lib/tailscale/tailscaled.state
sudo systemctl restart tailscaled
sudo tailscale up --login-server=http://38.47.227.223:8080 --authkey=<密钥>
```

### 常见问题

1. **服务无法启动**
   ```bash
   # 验证配置文件语法
   sudo headscale configtest 2>/dev/null || echo "配置检查命令不存在，直接查看日志"
   
   # 查看详细启动日志
   sudo journalctl -u headscale -f --since "5 minutes ago"
   ```

2. **客户端无法连接**
   ```bash
   # 检查防火墙
   sudo ufw status
   
   # 检查服务器可达性（重要：使用 HTTP）
   curl -I http://38.47.227.223:8080
   curl -I http://38.47.227.223:8080/health
   ```

3. **设备间无法通信**
   ```bash
   # 检查路由表和连接状态
   tailscale status
   tailscale netcheck
   
   # 测试连通性
   tailscale ping <target-device>
   
   # 检查网络接口
   ifconfig | grep -A 3 "100.64.0"
   ```

4. **节点显示离线但实际在线**
   ```bash
   # 服务器端：查看节点列表
   sudo headscale nodes list
   
   # 强制删除问题节点
   sudo headscale nodes delete --identifier <node-id> --force
   
   # 客户端：重新注册
   tailscale up --login-server=http://38.47.227.223:8080 --authkey=<密钥>
   ```

### 日志查看

```bash
# 服务器端日志
sudo journalctl -u headscale -f

# 客户端日志
sudo tailscale bugreport
```

## 高级配置

### HTTPS 配置

如果需要 HTTPS，可以使用 Let's Encrypt：

```bash
# 安装 certbot
sudo apt install certbot

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 修改配置文件
sudo nano /etc/headscale/config.yaml
# 设置 tls_cert_path 和 tls_key_path
```

### Web UI

可以安装第三方 Web 管理界面：

```bash
# 使用 headscale-ui
docker run -d \
  --name headscale-ui \
  -p 80:80 \
  -e HEADSCALE_URL=http://38.47.227.223:8080 \
  ghcr.io/gurucomputing/headscale-ui:latest
```

## 与 ZeroTier 对比

| 特性 | Headscale | ZeroTier 自建 |
|------|-----------|---------------|
| **部署复杂度** | ⭐⭐ 简单 | ⭐⭐⭐⭐⭐ 复杂 |
| **维护成本** | ⭐ 很低 | ⭐⭐⭐⭐ 高 |
| **性能** | ✅ WireGuard 内核级 | ⭐⭐⭐ 用户空间 |
| **官方节点问题** | ✅ 无硬编码 | ❌ 需要修改源码 |
| **客户端支持** | ✅ 全平台 | ✅ 全平台 |

## Tailscale 认证状态清理

在使用 Headscale 与 Tailscale 客户端时，有时需要完全清理客户端的认证状态以重新登录。下面提供了在不同系统上彻底清理 Tailscale 认证状态的方法：

### macOS 系统

#### 方法一：标准清理（推荐）

```bash
# 1. 登出当前账户
tailscale logout

# 2. 停止 Tailscale 服务
sudo tailscale down

# 3. 重新登录
tailscale up --login-server=http://38.47.227.223:8080 --authkey=<预认证密钥>
```

#### 方法二：彻底重置

```bash
# 1. 停止 Tailscale 服务
sudo launchctl stop system/com.tailscale.tailscaled

# 2. 卸载 Tailscale 后台服务
sudo launchctl bootout system /Library/LaunchDaemons/com.tailscale.tailscaled.plist

# 3. 删除配置文件和状态文件
sudo rm -rf /Library/Tailscale/
rm -rf ~/Library/Containers/io.tailscale.ipn.macos/
rm -rf ~/Library/Application\ Support/Tailscale/
rm -rf ~/Library/Caches/io.tailscale.ipn.macos/
rm -rf ~/Library/Preferences/io.tailscale.ipn.macos.plist

# 4. 清理钥匙串中的 Tailscale 条目（可选）
security delete-generic-password -s "Tailscale" ~/Library/Keychains/login.keychain-db 2>/dev/null || true

# 5. 重新启动 Tailscale 服务
sudo launchctl bootstrap system /Library/LaunchDaemons/com.tailscale.tailscaled.plist
sudo launchctl kickstart system/com.tailscale.tailscaled
```

#### 方法三：通过应用界面

1. 打开 Tailscale 应用
2. 点击菜单栏中的 Tailscale 图标
3. 选择账户设置
4. 点击 "Sign out" 或 "Log out"
5. 重新登录

### Ubuntu/Linux 系统

#### 方法一：标准清理（推荐）

```bash
# 1. 登出当前账户
sudo tailscale logout

# 2. 停止 Tailscale 服务
sudo tailscale down

# 3. 重新登录
sudo tailscale up --login-server=http://38.47.227.223:8080 --authkey=<预认证密钥>
```

#### 方法二：彻底重置

```bash
# 1. 停止 Tailscale 服务
sudo systemctl stop tailscaled

# 2. 禁用自启动（可选）
sudo systemctl disable tailscaled

# 3. 删除配置文件和状态文件
sudo rm -rf /var/lib/tailscale/
sudo rm -rf /etc/tailscale/
rm -rf ~/.config/tailscale/

# 4. 清理网络接口（如果存在）
sudo ip link delete tailscale0 2>/dev/null || true

# 5. 重启服务
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
```

#### 方法三：完全卸载重装

```bash
# 1. 停止服务
sudo systemctl stop tailscaled
sudo systemctl disable tailscaled

# 2. 卸载 Tailscale
sudo apt remove --purge tailscale

# 3. 删除残留文件
sudo rm -rf /var/lib/tailscale/
sudo rm -rf /etc/tailscale/
rm -rf ~/.config/tailscale/

# 4. 重新安装
curl -fsSL https://tailscale.com/install.sh | sh

# 5. 启动并登录
sudo systemctl enable --now tailscaled
sudo tailscale up --login-server=http://38.47.227.223:8080 --authkey=<预认证密钥>
```

### 验证清理结果

无论使用哪种方法，清理完成后可以通过以下命令验证：

```bash
# 检查 Tailscale 状态
tailscale status

# 应该显示 "Tailscale is stopped" 或未认证状态
```

### 常见问题

1. **清理后无法重新登录？**
   - 检查网络连接，确保防火墙没有阻止 Tailscale 的连接
   - 确认 Headscale 服务器可访问：`curl -I http://38.47.227.223:8080`
   - 验证预认证密钥是否有效且未过期

2. **设备在管理面板中仍显示在线？**
   - 在 Headscale 服务器上手动删除该设备：`sudo headscale nodes delete <node-id>`

3. **清理后系统网络异常？**
   - 重启网络服务或重启系统通常可以解决
   - 在 Ubuntu: `sudo systemctl restart networking`
   - 在 macOS: `sudo dscacheutil -flushcache`

## 🎉 成功案例验证

### 网络拓扑验证

成功部署后，你应该能看到类似以下的网络拓扑：

```bash
# 检查自己的设备信息
tailscale status
# 输出示例：
100.64.0.1      mini-xy-16           dev-team     macOS   -           # 当前设备
100.64.0.7      mac                  dev-team     macOS   offline
100.64.0.5      xiaoyown-mac         dev-team     macOS   offline  
100.64.0.8      xiaoyown             dev-team     linux   offline

# 检查网络接口
ifconfig | grep -A 3 "100.64.0"
# 输出示例：
	inet 100.64.0.1 --> 100.64.0.1 netmask 0xffffffff
	inet6 fd7a:115c:a1e0::1 --> fd7a:115c:a1e0::1 prefixlen 128

# 检查路由表
route -n get 100.64.0.0/10
# 输出示例：
   route to: 100.64.0.0
destination: 100.64.0.0
       mask: 255.192.0.0
  interface: utun0
```

### 网络连通性测试

```bash
# 1. 测试本机 Tailscale 接口
ping -c 3 100.64.0.1
# 预期：正常响应，延迟 < 1ms

# 2. 检查网络发现
tailscale netcheck
# 预期输出：
Report:
	* UDP: true
	* IPv4: yes, [你的公网IP]:端口
	* Nearest DERP: Custom DERP
	* DERP latency: ~50-100ms (Custom DERP)

# 3. 检查网络端点
tailscale debug netmap | jq '.SelfNode.Endpoints'
# 预期：显示多个网络端点，包括公网IP和私有网络IP
```

### IP地址分配规律

基于我们的实际操作，IP地址分配遵循以下规律：

- **网段**: `100.64.0.0/10` (Tailscale标准网段)
- **分配顺序**: 按设备注册顺序递增
- **IP示例**:
  - `100.64.0.1` - 第一台重新注册的设备
  - `100.64.0.5` - xiaoyown-mac
  - `100.64.0.7` - mac
  - `100.64.0.8` - xiaoyown (Linux)
  - `100.64.0.9` - 之前的 mini-xy-16 (已删除)

### 公网IP和网络环境

```bash
# 查看你的公网出口IP信息
curl -s http://ipinfo.io/[你的公网IP] | jq
# 这个IP会显示在 tailscale netcheck 的 IPv4 字段中
```

**网络拓扑关系**：
```
客户端设备 (深圳) ←→ 121.35.47.22 (公网出口)
                   ↓
              互联网路由
                   ↓  
            38.47.227.223:8080 (新加坡 Headscale服务器)
                   ↑
              DERP中继服务 + 控制平面
                   ↓
            其他Tailscale节点
```

### 健康检查通过标准

✅ **正常工作的标志**：

```bash
tailscale status
# ✅ 显示你的设备为 "-"（当前设备）
# ✅ 没有HTTPS连接错误
# ✅ 其他设备显示相应状态（online/offline）

tailscale netcheck
# ✅ UDP: true
# ✅ IPv4: yes, [公网IP]:[端口]
# ✅ DERP latency 正常（通常 < 200ms）

ifconfig | grep "100.64.0"
# ✅ 显示正确的 Tailscale IP 地址

ping -c 1 100.64.0.1
# ✅ 能够 ping 通自己的 Tailscale IP
```

## 总结

Headscale 提供了比 ZeroTier 自建 planet 更简单、更可靠的解决方案：

- **部署时间**: 30分钟 vs 数小时
- **维护复杂度**: 几乎零维护 vs 持续调试
- **性能**: WireGuard 内核级性能
- **稳定性**: 无官方节点硬编码问题

### 🔑 关键经验总结

1. **DERP配置关键点**：
   - `http_listen_addr` 必须与 `listen_addr` 使用相同端口
   - 避免端口冲突，统一使用8080端口

2. **协议一致性**：
   - 服务器使用HTTP时，客户端必须用HTTP连接
   - 遇到协议不匹配时，需要完全清理客户端状态

3. **网络诊断要点**：
   - `netcheck` 显示网络发现能力
   - 公网IP不等于服务器IP，是正常的NAT行为
   - DERP延迟正常即表示中继服务工作正常

4. **故障排除思路**：
   - 先检查服务器端配置和日志
   - 再检查客户端连接和认证状态
   - 必要时清理客户端状态重新注册
