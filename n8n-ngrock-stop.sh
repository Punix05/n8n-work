#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMPOSE_DIR="/home/taise/n8n_work/n8n-compose/n8n-compose"

echo -e "${YELLOW}=== n8n + ngrok を停止中 ===${NC}\n"

# Docker Composeを停止
echo -e "${YELLOW}[1/2] n8nコンテナを停止中...${NC}"
cd "$COMPOSE_DIR"
docker compose down

# ngrokを停止
echo -e "${YELLOW}[2/2] ngrokを停止中...${NC}"
if [ -f /tmp/ngrok.pid ]; then
    NGROK_PID=$(cat /tmp/ngrok.pid)
    kill $NGROK_PID 2>/dev/null
    rm /tmp/ngrok.pid
fi
pkill -f ngrok

echo -e "\n${GREEN}✓ 停止完了${NC}"