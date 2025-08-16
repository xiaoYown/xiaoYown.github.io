#!/bin/bash

# ZeroTier 自建 Planet 节点部署脚本
# chmod +x zerotier-custom-planet-setup.sh
# 使用方法: sudo bash zerotier-custom-planet-setup.sh <公网IP>

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_important() {
    echo -e "${CYAN}[IMPORTANT]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "请使用 root 权限运行此脚本: sudo bash $0"
        exit 1
    fi
}

# 检查参数
check_args() {
    if [ $# -ne 1 ]; then
        log_error "使用方法: $0 <公网IP>"
        log_error "示例: $0 1.2.3.4"
        exit 1
    fi
    
    PUBLIC_IP=$1
    
    # 简单的IP格式验证
    if ! [[ $PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "IP地址格式不正确: $PUBLIC_IP"
        exit 1
    fi
}

# 安装 ZeroTier
install_zerotier() {
    log_step "检查并安装 ZeroTier..."
    
    # 检查是否已安装
    if command -v zerotier-cli &> /dev/null; then
        log_info "ZeroTier 已安装，版本: $(zerotier-cli -v)"
    else
        # 安装 ZeroTier
        log_info "正在安装 ZeroTier..."
        curl -s https://install.zerotier.com | bash
        
        if ! command -v zerotier-cli &> /dev/null; then
            log_error "ZeroTier 安装失败"
            exit 1
        fi
        
        log_info "ZeroTier 安装完成"
    fi
}

# 停止 ZeroTier 服务
stop_zerotier() {
    log_step "停止 ZeroTier 服务..."
    systemctl stop zerotier-one || true
    sleep 2
}

# 生成自定义 Planet 配置
generate_custom_planet() {
    log_step "生成自定义 Planet 配置..."
    
    # 创建工作目录
    WORK_DIR="/tmp/zerotier-custom-planet-$$"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    log_info "工作目录: $WORK_DIR"
    
    # 生成新的身份文件
    log_info "生成 Planet 身份文件..."
    zerotier-idtool generate identity.secret identity.public
    
    # 获取节点ID
    PLANET_ID=$(zerotier-idtool getpublic identity.secret)
    log_info "Planet 节点ID: $PLANET_ID"
    
    # 生成初始 moon.json
    zerotier-idtool initmoon identity.public > moon.json
    
    # 修改 moon.json 配置
    log_info "配置 Planet 端点: $PUBLIC_IP:9993"
    
    # 使用 sed 修改配置
    sed -i "s/\"stableEndpoints\": \[\]/\"stableEndpoints\": [\"$PUBLIC_IP\/9993\"]/" moon.json
    
    # 生成 .moon 文件
    zerotier-idtool genmoon moon.json
    
    # 获取生成的 .moon 文件
    MOON_FILE=$(ls *.moon 2>/dev/null | head -n1)
    
    if [ -z "$MOON_FILE" ]; then
        log_error "生成 .moon 文件失败"
        exit 1
    fi
    
    log_info "生成的 Moon 文件: $MOON_FILE"
    
    # 创建自定义 planet 文件（使用 .moon 文件作为 planet）
    cp "$MOON_FILE" custom-planet
    
    log_info "自定义 Planet 文件已生成: custom-planet"
}

# 配置 ZeroTier 使用自定义 Planet
configure_custom_planet() {
    log_step "配置 ZeroTier 使用自定义 Planet..."
    
    # 确保 ZeroTier 目录存在
    mkdir -p /var/lib/zerotier-one/moons.d
    
    # 备份原始 planet 文件
    if [ -f /var/lib/zerotier-one/planet ]; then
        cp /var/lib/zerotier-one/planet /var/lib/zerotier-one/planet.original.bak
        log_info "已备份原始 planet 文件"
    fi
    
    # 复制身份文件到 ZeroTier 目录
    cp identity.secret identity.public /var/lib/zerotier-one/
    
    # 使用自定义 planet 文件
    cp custom-planet /var/lib/zerotier-one/planet
    
    # 同时将 moon 文件放到 moons.d 目录
    cp "$MOON_FILE" /var/lib/zerotier-one/moons.d/
    
    log_info "自定义 Planet 配置完成"
}

# 启动 ZeroTier 服务
start_zerotier() {
    log_step "启动 ZeroTier 服务..."
    
    systemctl enable zerotier-one
    systemctl start zerotier-one
    
    # 等待服务启动
    sleep 5
    
    if ! systemctl is-active --quiet zerotier-one; then
        log_error "ZeroTier 服务启动失败"
        exit 1
    fi
    
    log_info "ZeroTier 服务已启动"
}

# 显示节点状态
show_status() {
    log_step "显示节点状态..."
    
    echo
    log_info "=== ZeroTier 节点信息 ==="
    zerotier-cli info || log_warn "无法获取节点信息"
    
    echo
    log_info "=== Planet 文件信息 ==="
    ls -la /var/lib/zerotier-one/planet
    
    echo
    log_info "=== Moon 文件信息 ==="
    ls -la /var/lib/zerotier-one/moons.d/ 2>/dev/null || log_warn "moons.d 目录为空"
    
    echo
    log_info "=== 当前 Peers ==="
    zerotier-cli peers || log_warn "无法获取 peers 信息"
}

# 生成客户端配置包
generate_client_package() {
    log_step "生成客户端配置包..."
    
    # 创建客户端配置目录
    CLIENT_DIR="/root/zerotier-custom-planet-client"
    mkdir -p "$CLIENT_DIR"
    
    # 复制 planet 和 moon 文件
    cp /var/lib/zerotier-one/planet "$CLIENT_DIR/planet"
    cp /var/lib/zerotier-one/moons.d/*.moon "$CLIENT_DIR/" 2>/dev/null || true
    
    MOON_FILE_NAME=$(basename /var/lib/zerotier-one/moons.d/*.moon 2>/dev/null | head -n1)
    
    # 生成客户端安装脚本
    cat > "$CLIENT_DIR/install-custom-planet.sh" << 'EOF'
#!/bin/bash
# ZeroTier 自定义 Planet 客户端配置脚本

set -e

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
    log_error "请使用 root 权限运行此脚本"
    exit 1
fi

log_info "开始配置 ZeroTier 自定义 Planet..."

# 检查并安装 ZeroTier
if ! command -v zerotier-cli &> /dev/null; then
    log_info "正在安装 ZeroTier..."
    curl -s https://install.zerotier.com | bash
fi

# 停止服务
log_info "停止 ZeroTier 服务..."
systemctl stop zerotier-one || true

# 备份原始文件
if [ -f /var/lib/zerotier-one/planet ]; then
    cp /var/lib/zerotier-one/planet /var/lib/zerotier-one/planet.original.bak.$(date +%Y%m%d_%H%M%S)
    log_info "已备份原始 planet 文件"
fi

# 创建必要目录
mkdir -p /var/lib/zerotier-one/moons.d

# 复制自定义 planet 文件
if [ -f "planet" ]; then
    cp planet /var/lib/zerotier-one/planet
    log_info "已安装自定义 planet 文件"
else
    log_error "未找到 planet 文件"
    exit 1
fi

# 复制 moon 文件
for moon_file in *.moon; do
    if [ -f "$moon_file" ]; then
        cp "$moon_file" /var/lib/zerotier-one/moons.d/
        log_info "已安装 moon 文件: $moon_file"
    fi
done

# 启动服务
log_info "启动 ZeroTier 服务..."
systemctl enable zerotier-one
systemctl start zerotier-one

# 等待服务启动
sleep 5

log_info "配置完成！"
log_info "节点信息:"
zerotier-cli info

echo
log_info "========================================="
log_info "自定义 Planet 配置完成！"
log_info "========================================="
log_info "现在可以使用以下命令加入网络:"
log_info "sudo zerotier-cli join <NETWORK_ID>"
log_info ""
log_info "注意: 网络ID 必须是在自定义 Planet 上创建的网络"
log_info "========================================="
EOF

    chmod +x "$CLIENT_DIR/install-custom-planet.sh"
    
    # 生成详细说明文档
    cat > "$CLIENT_DIR/README.md" << EOF
# ZeroTier 自定义 Planet 客户端配置

## 服务器信息
- 自定义 Planet 节点 ID: $PLANET_ID
- 服务器公网 IP: $PUBLIC_IP
- 服务端口: 9993/udp, 9993/tcp
- 生成时间: $(date)

## 重要说明
⚠️ **使用自定义 Planet 后，客户端将无法连接到 ZeroTier 官方网络！**
⚠️ **所有网络必须在自定义 Planet 上创建和管理！**

## 客户端配置步骤

### 1. 下载配置包
将整个目录下载到客户端，包含：
- \`planet\` - 自定义 Planet 文件
- \`*.moon\` - Moon 配置文件
- \`install-custom-planet.sh\` - 自动安装脚本

### 2. 运行安装脚本
\`\`\`bash
sudo bash install-custom-planet.sh
\`\`\`

### 3. 创建网络
由于使用了自定义 Planet，你需要：
1. 在服务器上创建网络控制器
2. 或使用第三方网络控制器
3. 无法使用 ZeroTier 官方的 my.zerotier.com

### 4. 加入网络
\`\`\`bash
sudo zerotier-cli join <NETWORK_ID>
\`\`\`

### 5. 验证连接
\`\`\`bash
# 查看节点状态
sudo zerotier-cli info

# 查看 peers（应该能看到自定义 Planet）
sudo zerotier-cli peers

# 查看网络列表
sudo zerotier-cli listnetworks
\`\`\`

## 网络管理

### 选项1: 使用 ZeroTier Controller
在服务器上安装网络控制器：
\`\`\`bash
# 安装 zerotier-controller
sudo apt install zerotier-controller  # Ubuntu/Debian
# 或
sudo yum install zerotier-controller   # CentOS/RHEL
\`\`\`

### 选项2: 使用第三方控制器
- [ztncui](https://github.com/key-networks/ztncui)
- [ZeroUI](https://github.com/dec0dOS/zero-ui)

## 恢复到官方 Planet

如需恢复到官方 Planet：
\`\`\`bash
sudo systemctl stop zerotier-one
sudo rm /var/lib/zerotier-one/planet
sudo mv /var/lib/zerotier-one/planet.original.bak /var/lib/zerotier-one/planet
sudo rm -rf /var/lib/zerotier-one/moons.d/*
sudo systemctl start zerotier-one
\`\`\`

## 防火墙配置

确保服务器防火墙开放端口：
\`\`\`bash
# Ubuntu/Debian
sudo ufw allow 9993

# CentOS/RHEL
sudo firewall-cmd --add-port=9993/udp --permanent
sudo firewall-cmd --add-port=9993/tcp --permanent
sudo firewall-cmd --reload
\`\`\`

## 故障排除

### 客户端无法连接
1. 检查防火墙设置
2. 确认服务器 IP 地址正确
3. 验证 planet 文件是否正确复制

### 查看日志
\`\`\`bash
sudo journalctl -u zerotier-one -f
\`\`\`
EOF

    # 复制配置信息到工作目录
    echo "PLANET_ID=$PLANET_ID" > "$CLIENT_DIR/server-info.txt"
    echo "PUBLIC_IP=$PUBLIC_IP" >> "$CLIENT_DIR/server-info.txt"
    echo "GENERATED_TIME=$(date)" >> "$CLIENT_DIR/server-info.txt"
    
    log_info "客户端配置包已生成到: $CLIENT_DIR"
    log_info "包含文件:"
    ls -la "$CLIENT_DIR"
}

# 清理临时文件
cleanup() {
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        log_info "清理临时文件: $WORK_DIR"
        rm -rf "$WORK_DIR"
    fi
}

# 显示完成信息
show_completion() {
    echo
    log_important "========================================="
    log_important "ZeroTier 自定义 Planet 节点部署完成！"
    log_important "========================================="
    echo
    log_info "服务器信息:"
    log_info "  - Planet 节点 ID: $PLANET_ID"
    log_info "  - 公网 IP: $PUBLIC_IP"
    log_info "  - 监听端口: 9993/udp, 9993/tcp"
    echo
    log_info "客户端配置:"
    log_info "  - 配置包目录: /root/zerotier-custom-planet-client/"
    log_info "  - 将整个目录分发给客户端"
    log_info "  - 客户端运行: sudo bash install-custom-planet.sh"
    echo
    log_warn "重要提醒:"
    log_warn "  ⚠️  使用自定义 Planet 后无法连接官方网络"
    log_warn "  ⚠️  需要自建网络控制器或使用第三方控制器"
    log_warn "  ⚠️  所有客户端都必须使用相同的 planet 文件"
    echo
    log_info "下一步操作:"
    log_info "  1. 确保防火墙开放 9993 端口"
    log_info "  2. 安装网络控制器（zerotier-controller 或第三方）"
    log_info "  3. 将客户端配置包分发给所有需要连接的设备"
    log_info "  4. 在控制器上创建网络并管理客户端"
    echo
    log_important "========================================="
}

# 主函数
main() {
    log_important "开始部署 ZeroTier 自定义 Planet 节点..."
    log_info "公网IP: $PUBLIC_IP"
    echo
    
    # 设置清理陷阱
    trap cleanup EXIT
    
    install_zerotier
    stop_zerotier
    generate_custom_planet
    configure_custom_planet
    start_zerotier
    show_status
    generate_client_package
    show_completion
}

# 脚本入口
check_root
check_args "$@"
main
