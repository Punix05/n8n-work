#!/bin/bash

# 色の設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GRAY='\033[0;37m'
NC='\033[0m'

# 作業ディレクトリ
COMPOSE_DIR="/home/taise/n8n_work/n8n-compose/n8n-compose"

echo -e "${GREEN}=== n8n Docker Compose + ngrok 自動起動 ===${NC}\n"

# 1. 既存のコンテナを停止
echo -e "${YELLOW}[1/6] 既存のn8nコンテナを停止中...${NC}"
cd "$COMPOSE_DIR"
docker compose down
sleep 2

# 2. 既存のngrokプロセスを停止
echo -e "${YELLOW}[2/6] 既存のngrokプロセスを停止中...${NC}"
pkill -f ngrok
sleep 1

# 3. ngrokをバックグラウンドで起動
echo -e "${YELLOW}[3/6] ngrokを起動中...${NC}"
ngrok http 5678 > /dev/null &
NGROK_PID=$!
sleep 3

# 4. ngrok APIからURLを取得
echo -e "${YELLOW}[4/6] ngrok URLを取得中...${NC}"
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | grep -o 'https://[^"]*' | head -n 1)

if [ -z "$NGROK_URL" ]; then
    echo -e "${RED}✗ エラー: ngrok URLを取得できませんでした${NC}"
    kill $NGROK_PID
    exit 1
fi

echo -e "${GREEN}✓ ngrok URL: $NGROK_URL${NC}"

# 5. .envファイルを作成/更新
echo -e "${YELLOW}[5/6] .envファイルを更新中...${NC}"
cat > "$COMPOSE_DIR/.env" << EOF
# 自動生成された環境変数 ($(date))
WEBHOOK_URL=$NGROK_URL/
N8N_HOST=$NGROK_URL
WEBHOOK_TUNNEL_URL=$NGROK_URL/
EOF

echo -e "${GREEN}✓ .envファイルを作成しました${NC}"

# 6. Docker Composeでn8nを起動
echo -e "${YELLOW}[6/6] n8nコンテナを起動中...${NC}"
docker compose up -d

# 起動完了まで待機
echo -e "${YELLOW}n8nの起動を待機中...${NC}"
sleep 5

# コンテナの状態を確認
if docker compose ps | grep -q "Up"; then
    echo -e "\n${GREEN}=== 起動完了 ===${NC}"
    echo -e "${CYAN}n8nにアクセス: $NGROK_URL${NC}"
    echo -e "${CYAN}Webhook URL形式: $NGROK_URL/webhook/[ID]/webhook${NC}"
    echo -e "\n${GRAY}ログを確認: docker compose logs -f${NC}"
    echo -e "${GRAY}停止: docker compose down && pkill -f ngrok${NC}\n"
else
    echo -e "\n${RED}✗ エラー: n8nコンテナの起動に失敗しました${NC}"
    echo -e "${YELLOW}ログを確認してください: docker compose logs${NC}"
    exit 1
fi

# バックグラウンドで実行するため、プロセスIDを保存
echo $NGROK_PID > /tmp/ngrok.pid

echo -e "${GREEN}ngrokはバックグラウンドで実行中 (PID: $NGROK_PID)${NC}"