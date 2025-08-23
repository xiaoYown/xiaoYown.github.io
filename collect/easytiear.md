# 部署脚本(deploy_easytier.sh)

```sh
#!/bin/bash

# EasyTier Web Service 部署脚本

echo "正在部署 EasyTier Web Service..."

# 创建 systemd 服务文件
sudo tee /etc/systemd/system/easytier.service > /dev/null << 'EOF'
[Unit]
Description=EasyTier Web Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/et
ExecStart=/etc/et/easytier-web-embed
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "✅ 服务配置文件已写入 /etc/systemd/system/easytier.service"

# 重新加载 systemd
echo "正在重新加载 systemd..."
sudo systemctl daemon-reload

# 启用服务（开机自启）
echo "正在启用服务..."
sudo systemctl enable easytier

echo "✅ 服务已启用（开机自启）"

# 启动服务
echo "正在启动服务..."
sudo systemctl start easytier

# 检查服务状态
echo "检查服务状态..."
sudo systemctl status easytier --no-pager

echo ""
echo "🎉 部署完成！"
echo ""
echo "常用命令："
echo "  查看状态: sudo systemctl status easytier"
echo "  停止服务: sudo systemctl stop easytier"
echo "  重启服务: sudo systemctl restart easytier"
echo "  查看日志: sudo journalctl -u easytier -f"
echo "  禁用开机启动: sudo systemctl disable easytier"
```

# 说明

embed 启动了 3 个服务

｜ 服务 ｜ 说明 ｜ 端口 ｜ 协议 ｜
｜-｜-｜-｜-｜
｜ api-server ｜ 后面前端需要连接的 ｜ 默认 11211，tcp，反代后那就是你自己 https 的端口 ｜ tcp ｜
｜ web-server ｜ 前端 dashboard ｜ 默认 11211，tcp，反代后那就是你自己 https 的端口 ｜ tcp ｜
｜ config-server ｜ 后续节点需要链接的，需要你服务器防火墙单独开放这个端口 ｜ 默认 22020，udp ｜ udp ｜

# 启动核心服务

## 正常启动

sudo ./easytier-core --config-server udp://38.47.227.223:22020/xiaoyown




