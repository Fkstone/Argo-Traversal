#!/bin/bash

# 检查 cloudflared 是否安装
if ! command -v cloudflared &> /dev/null
then
    echo "cloudflared 未安装，正在尝试安装..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    if ! command -v cloudflared &> /dev/null
    then
        echo "cloudflared 安装失败，请手动安装。"
        exit 1
    fi
fi

echo "cloudflared 已安装。"

# 登录 Cloudflare 并授权 cloudflared
echo "请在浏览器中完成 Cloudflare Tunnel 登录..."
cloudflared tunnel login

# 创建隧道
read -p "请输入隧道名称: " TUNNEL_NAME
cloudflared tunnel create $TUNNEL_NAME

# 获取隧道 ID
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')

if [ -z "$TUNNEL_ID" ]; then
    echo "隧道创建失败。"
    exit 1
fi

echo "隧道创建成功，ID: $TUNNEL_ID"

# 获取凭证文件路径
CREDENTIALS_FILE="$HOME/.cloudflared/$TUNNEL_ID.json"

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "未找到凭证文件。"
    exit 1
fi

# 配置隧道
read -p "请输入你想要穿透的本地服务地址 (如 http://localhost:8080): " LOCAL_URL
read -p "请输入你的域名 (如 example.com): " DOMAIN_NAME
read -p "请输入子域名前缀 (如 tunnel): " SUBDOMAIN_PREFIX

CONFIG_PATH="/etc/cloudflared"
sudo mkdir -p $CONFIG_PATH

# 复制凭证文件到配置目录
sudo cp "$CREDENTIALS_FILE" "$CONFIG_PATH/$TUNNEL_ID.json"

# 修改凭证文件和目录的权限
sudo chown -R nobody:nogroup $CONFIG_PATH
sudo chmod -R 750 $CONFIG_PATH
sudo chmod 640 $CONFIG_PATH/$TUNNEL_ID.json

YML_PATH="$CONFIG_PATH/$TUNNEL_NAME.yml"
cat << EOF | sudo tee $YML_PATH
tunnel: $TUNNEL_ID
credentials-file: $CONFIG_PATH/$TUNNEL_ID.json

ingress:
  - hostname: $SUBDOMAIN_PREFIX.$DOMAIN_NAME
    service: $LOCAL_URL
  - service: http_status:404
EOF

# 修改配置文件的权限
sudo chown nobody:nogroup $YML_PATH
sudo chmod 640 $YML_PATH

echo "隧道配置文件创建完成。"

# 配置 DNS 记录
echo "配置 DNS 记录..."
cloudflared tunnel route dns $TUNNEL_NAME $SUBDOMAIN_PREFIX.$DOMAIN_NAME

# 创建 systemd 服务单元文件
SERVICE_FILE="/etc/systemd/system/cloudflared-$TUNNEL_NAME.service"
sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Cloudflare Tunnel for $TUNNEL_NAME
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel --config $YML_PATH run
Restart=always
User=nobody
Group=nogroup
Environment=LOG_FILE=$CONFIG_PATH/cloudflared.log
StandardOutput=file:$CONFIG_PATH/cloudflared.log
StandardError=file:$CONFIG_PATH/cloudflared.log

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 并启用服务
sudo systemctl daemon-reload
sudo systemctl enable cloudflared-$TUNNEL_NAME.service
sudo systemctl start cloudflared-$TUNNEL_NAME.service

echo "隧道已在后台运行，并已配置为开机自动启动。"
echo "你可以通过 https://$SUBDOMAIN_PREFIX.$DOMAIN_NAME 访问你的本地服务。"
echo "日志文件位于: $CONFIG_PATH/cloudflared.log"
