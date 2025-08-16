#!/bin/bash

# ZeroTier 完整卸载脚本
# 使用方法: sudo bash zerotier-complete-uninstall.sh

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

# 确认卸载
confirm_uninstall() {
    echo
    log_important "========================================="
    log_important "ZeroTier 完整卸载脚本"
    log_important "========================================="
    echo
    log_warn "此脚本将完全卸载 ZeroTier 并清理所有相关文件："
    log_warn "  - 停止并删除 ZeroTier 服务"
    log_warn "  - 卸载 ZeroTier 软件包"
    log_warn "  - 删除所有配置文件和数据"
    log_warn "  - 清理网络接口"
    log_warn "  - 删除用户和组"
    echo
    log_error "⚠️  警告：此操作不可逆！所有 ZeroTier 网络连接将断开！"
    echo
    
    read -p "确定要继续卸载吗？(输入 'YES' 确认): " confirm
    if [ "$confirm" != "YES" ]; then
        log_info "取消卸载操作"
        exit 0
    fi
    echo
}

# 停止 ZeroTier 服务
stop_services() {
    log_step "停止 ZeroTier 服务..."
    
    # 停止服务
    if systemctl is-active --quiet zerotier-one 2>/dev/null; then
        systemctl stop zerotier-one
        log_info "已停止 zerotier-one 服务"
    else
        log_warn "zerotier-one 服务未运行"
    fi
    
    # 禁用服务
    if systemctl is-enabled --quiet zerotier-one 2>/dev/null; then
        systemctl disable zerotier-one
        log_info "已禁用 zerotier-one 服务"
    else
        log_warn "zerotier-one 服务未启用"
    fi
    
    # 停止其他可能的 ZeroTier 进程
    pkill -f zerotier 2>/dev/null || true
    log_info "已终止所有 ZeroTier 进程"
}

# 清理网络接口
cleanup_network_interfaces() {
    log_step "清理 ZeroTier 网络接口..."
    
    # 查找并删除 ZeroTier 网络接口
    for interface in $(ip link show | grep -o 'zt[a-f0-9]*' 2>/dev/null || true); do
        if [ -n "$interface" ]; then
            ip link delete "$interface" 2>/dev/null || true
            log_info "已删除网络接口: $interface"
        fi
    done
    
    # 清理可能的 tun/tap 接口
    for interface in $(ip link show | grep -o 'zt.*:' | sed 's/:$//' 2>/dev/null || true); do
        if [ -n "$interface" ]; then
            ip link delete "$interface" 2>/dev/null || true
            log_info "已删除网络接口: $interface"
        fi
    done
}

# 卸载软件包
uninstall_packages() {
    log_step "卸载 ZeroTier 软件包..."
    
    # 检测系统类型并卸载
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu 系统
        log_info "检测到 Debian/Ubuntu 系统"
        
        # 卸载软件包
        apt-get remove --purge -y zerotier-one 2>/dev/null || log_warn "zerotier-one 包未安装或卸载失败"
        apt-get remove --purge -y zerotier-controller 2>/dev/null || log_warn "zerotier-controller 包未安装"
        
        # 清理依赖
        apt-get autoremove -y 2>/dev/null || true
        apt-get autoclean 2>/dev/null || true
        
        # 删除 APT 源
        rm -f /etc/apt/sources.list.d/zerotier.list
        rm -f /etc/apt/trusted.gpg.d/zerotier.gpg
        log_info "已删除 APT 源配置"
        
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL/Fedora 系统
        log_info "检测到 CentOS/RHEL/Fedora 系统"
        
        # 卸载软件包
        yum remove -y zerotier-one 2>/dev/null || log_warn "zerotier-one 包未安装或卸载失败"
        yum remove -y zerotier-controller 2>/dev/null || log_warn "zerotier-controller 包未安装"
        
        # 删除 YUM 源
        rm -f /etc/yum.repos.d/zerotier.repo
        log_info "已删除 YUM 源配置"
        
    elif command -v dnf &> /dev/null; then
        # Fedora 新版本
        log_info "检测到 Fedora 系统 (DNF)"
        
        # 卸载软件包
        dnf remove -y zerotier-one 2>/dev/null || log_warn "zerotier-one 包未安装或卸载失败"
        dnf remove -y zerotier-controller 2>/dev/null || log_warn "zerotier-controller 包未安装"
        
        # 删除 DNF 源
        rm -f /etc/yum.repos.d/zerotier.repo
        log_info "已删除 DNF 源配置"
        
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        log_info "检测到 Arch Linux 系统"
        
        # 卸载软件包
        pacman -Rns --noconfirm zerotier-one 2>/dev/null || log_warn "zerotier-one 包未安装或卸载失败"
        
    else
        log_warn "未识别的包管理器，跳过软件包卸载"
    fi
    
    log_info "软件包卸载完成"
}

# 删除文件和目录
remove_files() {
    log_step "删除 ZeroTier 文件和目录..."
    
    # 主要配置和数据目录
    directories_to_remove=(
        "/var/lib/zerotier-one"
        "/etc/zerotier"
        "/usr/local/etc/zerotier"
        "/opt/zerotier"
        "/var/log/zerotier-one"
    )
    
    for dir in "${directories_to_remove[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            log_info "已删除目录: $dir"
        fi
    done
    
    # 可执行文件
    executables_to_remove=(
        "/usr/sbin/zerotier-one"
        "/usr/bin/zerotier-cli"
        "/usr/bin/zerotier-idtool"
        "/usr/local/bin/zerotier-one"
        "/usr/local/bin/zerotier-cli"
        "/usr/local/bin/zerotier-idtool"
        "/opt/zerotier/bin/zerotier-one"
        "/opt/zerotier/bin/zerotier-cli"
        "/opt/zerotier/bin/zerotier-idtool"
    )
    
    for exe in "${executables_to_remove[@]}"; do
        if [ -f "$exe" ]; then
            rm -f "$exe"
            log_info "已删除可执行文件: $exe"
        fi
    done
    
    # systemd 服务文件
    systemd_files=(
        "/etc/systemd/system/zerotier-one.service"
        "/lib/systemd/system/zerotier-one.service"
        "/usr/lib/systemd/system/zerotier-one.service"
        "/etc/systemd/system/zerotier-controller.service"
        "/lib/systemd/system/zerotier-controller.service"
        "/usr/lib/systemd/system/zerotier-controller.service"
    )
    
    for service_file in "${systemd_files[@]}"; do
        if [ -f "$service_file" ]; then
            rm -f "$service_file"
            log_info "已删除服务文件: $service_file"
        fi
    done
    
    # 重新加载 systemd
    systemctl daemon-reload 2>/dev/null || true
    
    # 删除临时文件
    rm -rf /tmp/zerotier-* 2>/dev/null || true
    
    # 删除可能的配置文件
    rm -f /etc/default/zerotier-one 2>/dev/null || true
    rm -f /etc/sysconfig/zerotier-one 2>/dev/null || true
    
    log_info "文件清理完成"
}

# 删除用户和组
remove_users_groups() {
    log_step "删除 ZeroTier 用户和组..."
    
    # 删除用户
    if id "zerotier-one" &>/dev/null; then
        userdel zerotier-one 2>/dev/null || log_warn "删除用户 zerotier-one 失败"
        log_info "已删除用户: zerotier-one"
    fi
    
    # 删除组
    if getent group zerotier-one &>/dev/null; then
        groupdel zerotier-one 2>/dev/null || log_warn "删除组 zerotier-one 失败"
        log_info "已删除组: zerotier-one"
    fi
}

# 清理防火墙规则
cleanup_firewall() {
    log_step "清理防火墙规则..."
    
    # UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        ufw delete allow 9993 2>/dev/null || true
        log_info "已删除 UFW 规则"
    fi
    
    # firewalld (CentOS/RHEL/Fedora)
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --remove-port=9993/udp --permanent 2>/dev/null || true
        firewall-cmd --remove-port=9993/tcp --permanent 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_info "已删除 firewalld 规则"
    fi
    
    # iptables 清理（谨慎操作）
    # 这里只清理明显的 ZeroTier 规则，避免影响其他规则
    iptables -D INPUT -p udp --dport 9993 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 9993 -j ACCEPT 2>/dev/null || true
    
    log_info "防火墙规则清理完成"
}

# 清理客户端配置包
cleanup_client_packages() {
    log_step "清理客户端配置包..."
    
    # 删除可能的客户端配置目录
    client_dirs=(
        "/root/zerotier-moon-client"
        "/root/zerotier-custom-planet-client"
        "/root/zerotier-planet-client"
    )
    
    for dir in "${client_dirs[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            log_info "已删除客户端配置目录: $dir"
        fi
    done
    
    # 删除可能的脚本文件
    script_files=(
        "/root/zerotier-*.sh"
        "./zerotier-*.sh"
        "./planet-client"
        "./client-setup.sh"
    )
    
    for pattern in "${script_files[@]}"; do
        rm -f $pattern 2>/dev/null || true
    done
    
    log_info "客户端配置包清理完成"
}

# 验证卸载
verify_uninstall() {
    log_step "验证卸载结果..."
    
    echo
    log_info "=== 卸载验证 ==="
    
    # 检查服务状态
    if systemctl list-units --all | grep -q zerotier; then
        log_warn "仍有 ZeroTier 服务残留"
        systemctl list-units --all | grep zerotier
    else
        log_info "✓ 所有 ZeroTier 服务已清理"
    fi
    
    # 检查进程
    if pgrep -f zerotier >/dev/null 2>&1; then
        log_warn "仍有 ZeroTier 进程运行"
        pgrep -f zerotier
    else
        log_info "✓ 没有 ZeroTier 进程运行"
    fi
    
    # 检查可执行文件
    if command -v zerotier-cli &> /dev/null; then
        log_warn "zerotier-cli 仍然可用"
    else
        log_info "✓ zerotier-cli 已卸载"
    fi
    
    # 检查配置目录
    if [ -d "/var/lib/zerotier-one" ]; then
        log_warn "配置目录仍然存在: /var/lib/zerotier-one"
    else
        log_info "✓ 配置目录已清理"
    fi
    
    # 检查网络接口
    if ip link show | grep -q zt; then
        log_warn "仍有 ZeroTier 网络接口"
        ip link show | grep zt
    else
        log_info "✓ ZeroTier 网络接口已清理"
    fi
    
    echo
}

# 显示完成信息
show_completion() {
    echo
    log_important "========================================="
    log_important "ZeroTier 完整卸载完成！"
    log_important "========================================="
    echo
    log_info "已完成的清理操作："
    log_info "  ✓ 停止并删除所有 ZeroTier 服务"
    log_info "  ✓ 卸载 ZeroTier 软件包"
    log_info "  ✓ 删除所有配置文件和数据"
    log_info "  ✓ 清理网络接口"
    log_info "  ✓ 删除用户和组"
    log_info "  ✓ 清理防火墙规则"
    log_info "  ✓ 删除客户端配置包"
    echo
    log_info "如需重新安装 ZeroTier："
    log_info "  curl -s https://install.zerotier.com | sudo bash"
    echo
    log_important "========================================="
}

# 主函数
main() {
    check_root
    confirm_uninstall
    
    log_important "开始 ZeroTier 完整卸载..."
    echo
    
    stop_services
    cleanup_network_interfaces
    uninstall_packages
    remove_files
    remove_users_groups
    cleanup_firewall
    cleanup_client_packages
    verify_uninstall
    show_completion
}

# 脚本入口
main "$@"