#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.sing-box"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/sing-box.log"
SUBSCRIPTION_FILE="$CONFIG_DIR/sub.txt"
DECODED_FILE="$CONFIG_DIR/decoded.txt"
URL_FILE="$CONFIG_DIR/subscription_url.txt"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p "$CONFIG_DIR"

# 读取订阅 URL
if [[ ! -f "$URL_FILE" ]]; then
    echo "ERROR: subscription_url.txt not found at $URL_FILE"
    exit 1
fi
SUBSCRIPTION_URL=$(<"$URL_FILE")
if [[ -z "$SUBSCRIPTION_URL" ]]; then
    echo "ERROR: subscription_url.txt is empty"
    exit 1
fi

echo "[1] 下载订阅..."
curl -L "$SUBSCRIPTION_URL" -o "$SUBSCRIPTION_FILE"

echo "[2] 解码 Base64..."
base64 -d "$SUBSCRIPTION_FILE" > "$DECODED_FILE" 2>/dev/null \
    || base64 --decode "$SUBSCRIPTION_FILE" > "$DECODED_FILE"

head $DECODED_FILE

# ----------------------------
# 调用 Python 脚本解析 AnyTLS 节点
# ----------------------------
NODE_INDEX=${1:-0}  # 可选节点索引
PYTHON_SCRIPT="$SCRIPT_DIR/parse_anytls_nodes.py"
SELECTED_NODE_JSON=$(python3 "$PYTHON_SCRIPT" "$DECODED_FILE" "$NODE_INDEX")

# 解析 JSON
SERVER=$(echo "$SELECTED_NODE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['server'])")
PORT=$(echo "$SELECTED_NODE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['port'])")
PASSWORD=$(echo "$SELECTED_NODE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['password'])")
SNI=$(echo "$SELECTED_NODE_JSON" | python3 -c "import sys, json; n=json.load(sys.stdin); print(n['sni'] if n['sni'] else n['server'])")

echo "[3] 生成 sing-box 配置..."
cat > "$CONFIG_FILE" <<EOF
{
  "log": {"level": "info"},
  "inbounds": [{"type": "mixed", "tag": "mixed-in", "listen": "127.0.0.1", "listen_port": 7890}],
  "outbounds": [
    {"type": "anytls","tag": "anytls-out","server": "$SERVER","server_port": $PORT,"password": "$PASSWORD","tls":{"enabled": true,"server_name": "$SNI"}},
    {"type": "direct","tag": "direct"}
  ],
  "route": {"final": "anytls-out"}
}
EOF

echo "[4] 停掉已有 sing-box..."
pkill -f "sing-box run -c $CONFIG_FILE" 2>/dev/null || true

echo "[5] 启动 sing-box..."
nohup sing-box run -c "$CONFIG_FILE" > "$LOG_FILE" 2>&1 &

echo "sing-box started in background."
echo "log file: $LOG_FILE"
echo "config file: $CONFIG_FILE"
