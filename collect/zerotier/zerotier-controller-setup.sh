#!/bin/bash

# ZeroTier 网络控制器安装配置脚本
# 使用方法: sudo bash zerotier-controller-setup.sh

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

# 检查 ZeroTier 是否已安装
check_zerotier() {
    if ! command -v zerotier-cli &> /dev/null; then
        log_error "ZeroTier 未安装，请先安装 ZeroTier"
        log_error "运行: curl -s https://install.zerotier.com | sudo bash"
        exit 1
    fi
    
    if ! systemctl is-active --quiet zerotier-one; then
        log_error "ZeroTier 服务未运行，请先启动服务"
        log_error "运行: sudo systemctl start zerotier-one"
        exit 1
    fi
    
    log_info "ZeroTier 服务正常运行"
}

# 获取节点信息
get_node_info() {
    log_step "获取节点信息..."
    
    NODE_INFO=$(zerotier-cli info)
    NODE_ID=$(echo "$NODE_INFO" | cut -d' ' -f3)
    
    if [ -z "$NODE_ID" ]; then
        log_error "无法获取节点ID"
        exit 1
    fi
    
    log_info "节点ID: $NODE_ID"
    log_info "节点状态: $NODE_INFO"
}

# 创建网络
create_network() {
    log_step "创建 ZeroTier 网络..."
    
    # 生成网络ID（使用节点ID前10位 + 随机6位，总共16位）
    NETWORK_ID="${NODE_ID:0:10}$(openssl rand -hex 3)"
    
    # 创建网络配置目录
    NETWORK_DIR="/var/lib/zerotier-one/controller.d/network"
    mkdir -p "$NETWORK_DIR"
    
    # 创建网络配置文件
    cat > "$NETWORK_DIR/${NETWORK_ID}.json" << EOF
{
  "id": "$NETWORK_ID",
  "nwid": "$NETWORK_ID",
  "name": "Custom Network",
  "private": true,
  "enableBroadcast": true,
  "allowPassiveBridging": false,
  "v4AssignMode": {
    "zt": true
  },
  "v6AssignMode": {
    "6plane": false,
    "rfc4193": false,
    "zt": false
  },
  "mtu": 2800,
  "multicastLimit": 32,
  "creationTime": $(date +%s)000,
  "revision": 1,
  "routes": [
    {
      "target": "10.147.17.0/24",
      "via": null
    }
  ],
  "ipAssignmentPools": [
    {
      "ipRangeStart": "10.147.17.1",
      "ipRangeEnd": "10.147.17.254"
    }
  ],
  "rules": [
    {
      "type": "ACTION_ACCEPT"
    }
  ]
}
EOF

    log_info "网络已创建: $NETWORK_ID"
    log_info "网络配置文件: $NETWORK_DIR/${NETWORK_ID}.json"
}

# 启用控制器功能
enable_controller() {
    log_step "启用网络控制器功能..."
    
    # 创建控制器配置目录
    mkdir -p /var/lib/zerotier-one/controller.d
    
    # 重启 ZeroTier 服务以启用控制器
    systemctl restart zerotier-one
    sleep 3
    
    # 验证控制器状态
    if [ -d "/var/lib/zerotier-one/controller.d" ]; then
        log_info "网络控制器已启用"
    else
        log_error "网络控制器启用失败"
        exit 1
    fi
}

# 加入自己创建的网络
join_network() {
    log_step "将节点加入网络..."
    
    # 加入网络
    zerotier-cli join "$NETWORK_ID"
    sleep 2
    
    # 自动授权自己
    MEMBER_DIR="/var/lib/zerotier-one/controller.d/network/${NETWORK_ID}/member"
    mkdir -p "$MEMBER_DIR"
    
    # 创建成员配置文件
    cat > "$MEMBER_DIR/${NODE_ID}.json" << EOF
{
  "id": "$NODE_ID",
  "nwid": "$NETWORK_ID",
  "authorized": true,
  "activeBridge": false,
  "identity": "$(cat /var/lib/zerotier-one/identity.public)",
  "ipAssignments": ["10.147.17.1"],
  "revision": 1,
  "vMajor": 1,
  "vMinor": 0,
  "vRev": 0,
  "vProto": 0
}
EOF

    log_info "节点已加入网络并获得授权"
    log_info "分配的IP: 10.147.17.1"
}

# 创建网络管理脚本
create_management_scripts() {
    log_step "创建网络管理脚本..."
    
    # 创建管理脚本目录
    SCRIPTS_DIR="/root/zerotier-network-management"
    mkdir -p "$SCRIPTS_DIR"
    
    # 创建列出网络的脚本
    cat > "$SCRIPTS_DIR/list-networks.sh" << 'EOF'
#!/bin/bash
echo "=== ZeroTier 网络列表 ==="
for network_file in /var/lib/zerotier-one/controller.d/network/*.json; do
    if [ -f "$network_file" ]; then
        network_id=$(basename "$network_file" .json)
        network_name=$(jq -r '.name // "Unnamed"' "$network_file" 2>/dev/null || echo "Unknown")
        private=$(jq -r '.private // false' "$network_file" 2>/dev/null || echo "Unknown")
        echo "网络ID: $network_id"
        echo "网络名称: $network_name"
        echo "私有网络: $private"
        echo "配置文件: $network_file"
        echo "---"
    fi
done
EOF

    # 创建列出成员的脚本
    cat > "$SCRIPTS_DIR/list-members.sh" << 'EOF'
#!/bin/bash
if [ $# -ne 1 ]; then
    echo "使用方法: $0 <NETWORK_ID>"
    exit 1
fi

NETWORK_ID=$1
MEMBER_DIR="/var/lib/zerotier-one/controller.d/network/$NETWORK_ID/member"

echo "=== 网络 $NETWORK_ID 的成员列表 ==="
if [ -d "$MEMBER_DIR" ]; then
    for member_file in "$MEMBER_DIR"/*.json; do
        if [ -f "$member_file" ]; then
            member_id=$(basename "$member_file" .json)
            authorized=$(jq -r '.authorized // false' "$member_file" 2>/dev/null || echo "Unknown")
            ip_assignments=$(jq -r '.ipAssignments[]? // "无IP"' "$member_file" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
            echo "成员ID: $member_id"
            echo "已授权: $authorized"
            echo "分配IP: $ip_assignments"
            echo "配置文件: $member_file"
            echo "---"
        fi
    done
else
    echo "网络不存在或无成员"
fi
EOF

    # 创建授权成员的脚本
    cat > "$SCRIPTS_DIR/authorize-member.sh" << 'EOF'
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <NETWORK_ID> <MEMBER_ID>"
    exit 1
fi

NETWORK_ID=$1
MEMBER_ID=$2
MEMBER_FILE="/var/lib/zerotier-one/controller.d/network/$NETWORK_ID/member/$MEMBER_ID.json"

if [ -f "$MEMBER_FILE" ]; then
    # 更新授权状态
    jq '.authorized = true' "$MEMBER_FILE" > "${MEMBER_FILE}.tmp" && mv "${MEMBER_FILE}.tmp" "$MEMBER_FILE"
    echo "成员 $MEMBER_ID 已授权加入网络 $NETWORK_ID"
else
    echo "成员文件不存在: $MEMBER_FILE"
    echo "请确保成员已尝试加入网络"
fi
EOF

    # 创建分配IP的脚本
    cat > "$SCRIPTS_DIR/assign-ip.sh" << 'EOF'
#!/bin/bash
if [ $# -ne 3 ]; then
    echo "使用方法: $0 <NETWORK_ID> <MEMBER_ID> <IP_ADDRESS>"
    exit 1
fi

NETWORK_ID=$1
MEMBER_ID=$2
IP_ADDRESS=$3
MEMBER_FILE="/var/lib/zerotier-one/controller.d/network/$NETWORK_ID/member/$MEMBER_ID.json"

if [ -f "$MEMBER_FILE" ]; then
    # 分配IP地址
    jq --arg ip "$IP_ADDRESS" '.ipAssignments = [$ip]' "$MEMBER_FILE" > "${MEMBER_FILE}.tmp" && mv "${MEMBER_FILE}.tmp" "$MEMBER_FILE"
    echo "已为成员 $MEMBER_ID 分配IP: $IP_ADDRESS"
else
    echo "成员文件不存在: $MEMBER_FILE"
fi
EOF

    # 创建删除成员的脚本
    cat > "$SCRIPTS_DIR/remove-member.sh" << 'EOF'
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <NETWORK_ID> <MEMBER_ID>"
    exit 1
fi

NETWORK_ID=$1
MEMBER_ID=$2
MEMBER_FILE="/var/lib/zerotier-one/controller.d/network/$NETWORK_ID/member/$MEMBER_ID.json"

if [ -f "$MEMBER_FILE" ]; then
    rm "$MEMBER_FILE"
    echo "成员 $MEMBER_ID 已从网络 $NETWORK_ID 中移除"
else
    echo "成员文件不存在: $MEMBER_FILE"
fi
EOF

    # 设置执行权限
    chmod +x "$SCRIPTS_DIR"/*.sh
    
    log_info "管理脚本已创建到: $SCRIPTS_DIR"
}

# 显示网络状态
show_network_status() {
    log_step "显示网络状态..."
    
    echo
    log_info "=== 网络信息 ==="
    log_info "网络ID: $NETWORK_ID"
    log_info "网络名称: Custom Network"
    log_info "IP池: 10.147.17.1-10.147.17.254"
    log_info "网络类型: 私有网络"
    
    echo
    log_info "=== 节点状态 ==="
    zerotier-cli info
    
    echo
    log_info "=== 网络列表 ==="
    zerotier-cli listnetworks
    
    echo
    log_info "=== 管理命令 ==="
    log_info "查看网络: bash $SCRIPTS_DIR/list-networks.sh"
    log_info "查看成员: bash $SCRIPTS_DIR/list-members.sh $NETWORK_ID"
    log_info "授权成员: bash $SCRIPTS_DIR/authorize-member.sh $NETWORK_ID <MEMBER_ID>"
    log_info "分配IP: bash $SCRIPTS_DIR/assign-ip.sh $NETWORK_ID <MEMBER_ID> <IP>"
    log_info "移除成员: bash $SCRIPTS_DIR/remove-member.sh $NETWORK_ID <MEMBER_ID>"
}

# 显示完成信息
show_completion() {
    echo
    log_important "========================================="
    log_important "ZeroTier 网络控制器配置完成！"
    log_important "========================================="
    echo
    log_info "网络信息:"
    log_info "  - 网络ID: $NETWORK_ID"
    log_info "  - 控制器节点: $NODE_ID"
    log_info "  - IP范围: 10.147.17.1-10.147.17.254"
    echo
    log_info "客户端加入网络:"
    log_info "  sudo zerotier-cli join $NETWORK_ID"
    echo
    log_info "管理脚本位置:"
    log_info "  $SCRIPTS_DIR/"
    echo
    log_info "下一步操作:"
    log_info "  1. 客户端运行: sudo zerotier-cli join $NETWORK_ID"
    log_info "  2. 服务器授权: bash $SCRIPTS_DIR/authorize-member.sh $NETWORK_ID <客户端ID>"
    log_info "  3. 分配IP: bash $SCRIPTS_DIR/assign-ip.sh $NETWORK_ID <客户端ID> <IP地址>"
    echo
    log_important "========================================="
}

# 主函数
main() {
    log_important "开始配置 ZeroTier 网络控制器..."
    echo
    
    check_zerotier
    get_node_info
    enable_controller
    create_network
    join_network
    create_management_scripts
    show_network_status
    show_completion
}

# 脚本入口
check_root
main "$@"
