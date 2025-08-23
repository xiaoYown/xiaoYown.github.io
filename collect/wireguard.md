# WireGuard 内网穿透部署指南

> 完全自主控制的点对点 VPN 解决方案，无需依赖任何第三方服务

## 架构说明

```
客户端A ← → 中继服务器(公网) ← → 客户端B
   Mac            Ubuntu VPS           Windows/Linux
```

## 一、中继服务器部署（公网 VPS）

### 1.1 安装 WireGuard

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install wireguard wireguard-tools

# CentOS/RHEL
sudo yum install epel-release && sudo yum install wireguard-tools

# 验证安装
wg --version
```

### 1.2 生成服务器密钥

```bash
# 创建配置目录
sudo mkdir -p /etc/wireguard
cd /etc/wireguard

# 生成服务器密钥对
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key

# 设置权限
sudo chmod 600 server_private.key
```

### 1.3 创建服务器配置

```bash
sudo cat > /etc/wireguard/wg0.conf << 'EOL'
[Interface]
PrivateKey = SERVER_PRIVATE_KEY_HERE
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

# 开启 IP 转发和 NAT
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# 客户端配置会自动添加到这里
EOL

# 替换配置文件中的密钥
sudo sed -i "s/SERVER_PRIVATE_KEY_HERE/$(sudo cat server_private.key)/" /etc/wireguard/wg0.conf
```

### 1.4 开启系统转发

```bash
# 临时开启
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 调整网卡名称（如果不是 eth0）
ip route | grep default  # 查看默认网卡名称
# 如果不是 eth0，需要修改上面配置文件中的 eth0 为实际网卡名
```

### 1.5 启动 WireGuard 服务

```bash
# 启动服务
sudo wg-quick up wg0

# 设置开机自启
sudo systemctl enable wg-quick@wg0

# 检查状态
sudo wg show
```

### 1.6 防火墙配置

```bash
# UFW（Ubuntu）
sudo ufw allow 51820/udp
sudo ufw allow OpenSSH
sudo ufw --force enable

# Firewalld（CentOS）
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --reload

# 云服务商安全组也需要开放 51820 UDP 端口
```

## 二、客户端安装

### 2.1 macOS 客户端

```bash
# 安装 WireGuard 工具
brew install wireguard-tools

# 验证安装
wg --version
wg-quick --help
```

> **注意**：WireGuard 官方 App 在中国区 App Store 无法下载，建议使用 Homebrew 安装命令行版本。

### 2.2 Linux 客户端

```bash
# 安装
sudo apt install wireguard wireguard-tools  # Ubuntu/Debian
# sudo yum install wireguard-tools           # CentOS/RHEL
```

### 2.3 Windows 客户端

- 下载：https://www.wireguard.com/install/
- 安装 Windows 客户端

### 2.4 Android/iOS 客户端

- 应用商店搜索安装 "WireGuard"

## 三、客户端配置与连接

### 3.1 生成客户端密钥

```bash
# 在服务器或客户端执行
wg genkey | tee client_private.key | wg pubkey > client_public.key

# 查看生成的密钥
echo "私钥: $(cat client_private.key)"
echo "公钥: $(cat client_public.key)"
```

### 3.2 创建客户端配置文件

```bash
# 创建客户端配置文件
cat > ~/Desktop/wg-client.conf << EOL
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = <10.0.0.2>/24
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <SERVER_IP>:51820
AllowedIPs = 10.0.0.0/24
# 全流量代理使用: AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL
```

### 3.3 服务器添加客户端

```bash
# 手动添加客户端（这样不会被保存覆盖）
sudo wg set wg0 peer <CLIENT_PUBLIC_KEY> allowed-ips <10.0.0.2>/32

# 重启服务使配置生效
sudo wg-quick down wg0 && sudo wg-quick up wg0

# 查看服务器状态
sudo wg show
```

### 3.4 各平台连接方法

#### macOS 连接

```bash
# 配置
sudo mkdir -p /usr/local/etc/wireguard
sudo cp ~/Desktop/wg-client.conf /usr/local/etc/wireguard/wg0.conf
sudo chmod 600 /usr/local/etc/wireguard/wg0.conf

# 连接
sudo wg-quick up wg0

# 检查
sudo wg show

# 验证
ping 10.0.0.1

# 断开连接
sudo wg-quick down wg0
```

#### Linux 连接

```bash
# 配置
sudo cp ~/Desktop/wg-client.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# 连接
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0  # 开机自启

# 检查
sudo wg show
```

#### Windows 连接

1. 安装后点击 "添加隧道" → 导入 `wg-client.conf`
2. 点击 "激活" 连接

#### Android/iOS 连接

1. 导入配置文件或扫描二维码连接

## 四、验证和测试

### 4.1 连接验证

```bash
# 检查 WireGuard 状态
sudo wg show

# 测试内网连通性
ping 10.0.0.1  # 客户端 ping 服务器
ping <10.0.0.2>  # 服务器 ping 客户端

# 检查路由表
ip route show | grep wg0  # Linux
route get 10.0.0.0        # macOS

# 测试外网（如果配置了全流量代理）
curl ipinfo.io  # 查看当前公网 IP
```

### 4.2 性能测试

```bash
# 安装 iperf3
sudo apt install iperf3  # Ubuntu
brew install iperf3      # macOS

# 服务器端启动
iperf3 -s -B 10.0.0.1

# 客户端测试
iperf3 -c 10.0.0.1 -t 30
```

## 五、多客户端管理

### 5.1 添加新客户端

每个新客户端需要：

- **唯一的私钥对**
- **唯一的内网 IP**（如 10.0.0.3/24, 10.0.0.4/24）
- **在服务器添加对应的 Peer 配置**

```bash
# 为第二个客户端生成密钥
wg genkey | tee client2_private.key | wg pubkey > client2_public.key

# 服务器添加第二个客户端
sudo tee -a /etc/wireguard/wg0.conf << EOL

[Peer]
PublicKey = <CLIENT2_PUBLIC_KEY>
AllowedIPs = 10.0.0.3/32
EOL

# 重启服务
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

### 5.2 客户端互访配置

如果需要客户端之间直接通信：

```ini
# 客户端配置中修改 AllowedIPs
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = <10.0.0.2>/24
DNS = 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <SERVER_IP>:51820
AllowedIPs = 10.0.0.0/24  # 允许访问整个 WireGuard 网络
PersistentKeepalive = 25
```

## 六、故障排除

### 6.1 常见问题

1. **无法连接服务器**

   ```bash
   # 检查防火墙
   sudo ufw status
   sudo iptables -L -n

   # 检查端口监听
   sudo netstat -ulnp | grep 51820
   ```

2. **连接成功但无网络**

   ```bash
   # 检查 IP 转发
   cat /proc/sys/net/ipv4/ip_forward

   # 检查 NAT 规则
   sudo iptables -t nat -L -n -v
   ```

3. **DNS 解析问题**

   ```bash
   # 测试 DNS
   nslookup google.com

   # 临时修改 DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

4. **客户端连接但无法 ping 通服务器**

   ```bash
   # 检查网卡名称是否正确（常见问题）
   ip route | grep default

   # 如果不是 eth0，需要更新配置文件
   sudo sed -i 's/eth0/ens3/g' /etc/wireguard/wg0.conf  # 替换为实际网卡名

   # 重启服务
   sudo wg-quick down wg0 && sudo wg-quick up wg0

   # 检查是否添加了客户端
   sudo wg show  # 应该能看到客户端公钥
   ```

### 6.2 调试命令

```bash
# 查看详细日志
sudo journalctl -u wg-quick@wg0 -f

# 检查网络接口
ip addr show wg0
ifconfig wg0  # macOS

# 抓包分析
sudo tcpdump -i wg0 -n

# 测试连通性
traceroute 10.0.0.1
mtr 10.0.0.1
```

## 七、安全和维护

### 7.1 安全建议

```bash
# 定期更换密钥（每6个月）
wg genkey | tee new_private.key | wg pubkey > new_public.key

# 备份配置文件
sudo cp /etc/wireguard/wg0.conf /etc/wireguard/wg0.conf.backup.$(date +%Y%m%d)

# 限制配置文件权限
sudo chmod 600 /etc/wireguard/wg0.conf
sudo chown root:root /etc/wireguard/wg0.conf
```

### 7.2 监控脚本

```bash
# 创建连接状态检查脚本
cat > ~/check_wg.sh << 'EOL'
#!/bin/bash
echo "=== WireGuard 状态 ==="
sudo wg show
echo -e "\n=== 网络连通性 ==="
ping -c 3 10.0.0.1
echo -e "\n=== 当前公网 IP ==="
curl -s ipinfo.io/ip
EOL

chmod +x ~/check_wg.sh
```

### 7.3 自动重连脚本

```bash
# 创建自动重连脚本
cat > ~/wg_keepalive.sh << 'EOL'
#!/bin/bash
if ! ping -c 1 10.0.0.1 >/dev/null 2>&1; then
    echo "$(date): WireGuard 连接断开，正在重连..."
    sudo wg-quick down wg0
    sleep 5
    sudo wg-quick up wg0
fi
EOL

chmod +x ~/wg_keepalive.sh

# 添加到 crontab（每分钟检查一次）
echo "* * * * * $HOME/wg_keepalive.sh >> /tmp/wg_keepalive.log 2>&1" | crontab -
```

---

**完成！** 现在你有了一个完整的 WireGuard 内网穿透解决方案，包括服务器部署和各平台客户端接入指南。
