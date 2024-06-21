#!/bin/bash

# 获取隧道名称
read -p "请输入要删除的隧道名称: " TUNNEL_NAME

# 获取隧道 ID
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')

if [ -z "$TUNNEL_ID" ]; then
    echo "未找到指定名称的隧道。"
    exit 1
fi

# 停止并禁用 systemd 服务
sudo systemctl stop cloudflared-$TUNNEL_NAME.service
sudo systemctl disable cloudflared-$TUNNEL_NAME.service

# 删除 systemd 服务单元文件
sudo rm /etc/systemd/system/cloudflared-$TUNNEL_NAME.service
sudo systemctl daemon-reload

# 删除隧道配置文件和凭证文件
sudo rm /etc/cloudflared/$TUNNEL_ID.json
sudo rm /etc/cloudflared/$TUNNEL_NAME.yml

# 从 Cloudflare 中删除隧道
cloudflared tunnel delete $TUNNEL_NAME

echo "隧道已删除并停止。"
echo "请手动从 Cloudflare 管理面板中删除 DNS 记录。"
