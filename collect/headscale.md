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
    enabled: false
  urls:
    - https://controlplane.tailscale.com/derpmap/default
  # 注意: 如需自建 DERP 服务器，请参考后面的性能优化章节

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

#### 解决方案 1: 配置自建 DERP 服务器

在 Headscale 服务器 (38.47.227.223) 上启用内置 DERP：

```bash
# 修改配置文件
sudo nano /etc/headscale/config.yaml
```

更新 DERP 配置：

```yaml
derp:
  server:
    enabled: true
    region_id: 999
    region_code: "custom"
    region_name: "Custom DERP"
    stun_listen_addr: "0.0.0.0:3478"
    private_key_path: /var/lib/headscale/derp_server.key
  urls: []  # 移除官方 DERP 服务器
  auto_update_enabled: false
```

开放端口并重启：

```bash
# 开放 DERP 端口
sudo ufw allow 3478/udp

# 重启 Headscale
sudo systemctl restart headscale
```

#### 解决方案 2: 优化 Headscale 配置

```yaml
# 在 /etc/headscale/config.yaml 中添加/修改
server_url: http://38.47.227.223:8080

# 优化数据库连接
database:
  type: sqlite3
  sqlite:
    path: /var/lib/headscale/db.sqlite
    # 添加性能优化
    pragma:
      journal_mode: WAL
      synchronous: NORMAL

# 启用更激进的节点检查
ephemeral_node_inactivity_timeout: 10m
node_update_check_interval: 10s

# DNS 优化
dns:
  override_local_dns: true
  nameservers:
    global:
      - 223.5.5.5    # 阿里 DNS (中国大陆)
      - 119.29.29.29 # 腾讯 DNS
      - 1.1.1.1
  magic_dns: true
  base_domain: headscale.local
```

#### 解决方案 3: 客户端优化

在每个客户端上执行：

```bash
# 强制重新连接以获取新配置
sudo tailscale down
sudo tailscale up --login-server=http://38.47.227.223:8080 --force-reauth

# 启用更详细的日志以诊断问题
sudo tailscale up --login-server=http://38.47.227.223:8080 --verbose=2
```

#### 解决方案 4: 网络诊断和修复

1. **检查防火墙设置**：
```bash
# 在所有机器上确保 WireGuard 端口开放
sudo ufw allow 51820/udp

# 检查 iptables 规则
sudo iptables -L -n | grep -i tailscale
```

2. **测试直连能力**：
```bash
# 在一台机器上运行
tailscale netcheck --verbose

# 查看是否能建立直连
tailscale status --json | jq '.Peer[] | {Name: .HostName, Direct: .CurAddr, Relay: .Relay, LastSeen: .LastSeen}'
```

3. **重置网络状态**：
```bash
# 在问题机器上重置 Tailscale
sudo tailscale logout
sudo systemctl restart tailscaled
sudo tailscale up --login-server=http://38.47.227.223:8080 --authkey=<your-key>
```

### 性能监控

添加性能监控脚本：

```bash
#!/bin/bash
# 保存为 /usr/local/bin/headscale-perf-check.sh

echo "=== Headscale 性能检查 ==="
echo "时间: $(date)"
echo

echo "=== 节点状态 ==="
sudo headscale nodes list
echo

echo "=== 客户端网络检查 ==="
tailscale netcheck
echo

echo "=== 节点连接状态 ==="
tailscale status
echo

echo "=== ping 测试 ==="
for ip in $(tailscale status --json | jq -r '.Peer[] | .TailscaleIPs[0]'); do
    echo -n "Ping $ip: "
    ping -c 1 -W 2 $ip > /dev/null 2>&1 && echo "OK" || echo "FAIL"
done
```

使脚本可执行：
```bash
sudo chmod +x /usr/local/bin/headscale-perf-check.sh
```

### 预期效果

正确配置后，你应该看到：
- `tailscale status` 显示节点为 `direct` 连接而不是 `relay`
- ping 延迟 < 50ms (局域网) 或 < 100ms (广域网)
- 文件传输速度接近网络带宽上限

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

### 常见问题

1. **服务无法启动**
   ```bash
   # 验证配置文件（通过尝试启动服务来检查）
   sudo headscale serve --check-config
   
   # 查看服务日志
   sudo journalctl -u headscale -f
   ```

2. **客户端无法连接**
   ```bash
   # 检查防火墙
   sudo ufw status
   
   # 检查服务器可达性
   curl -I http://38.47.227.223:8080
   ```

3. **设备间无法通信**
   ```bash
   # 检查路由表
   tailscale status
   
   # 测试连通性
   tailscale ping <target-device>
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

## 总结

Headscale 提供了比 ZeroTier 自建 planet 更简单、更可靠的解决方案：

- **部署时间**: 30分钟 vs 数小时
- **维护复杂度**: 几乎零维护 vs 持续调试
- **性能**: WireGuard 内核级性能
- **稳定性**: 无官方节点硬编码问题