#!/bin/bash

# 色の設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== n8n 環境変数検証スクリプト ===${NC}\n"

COMPOSE_DIR="/home/user/n8n-work/n8n-compose/n8n-compose"

# 1. .envファイルの確認
echo -e "${YELLOW}[1/4] .envファイルの確認...${NC}"
if [ -f "$COMPOSE_DIR/.env" ]; then
    echo -e "${GREEN}✓ .envファイルが存在します${NC}"
    echo -e "${CYAN}内容:${NC}"
    cat "$COMPOSE_DIR/.env" | grep -v "^#" | grep -v "^$"
    echo ""
else
    echo -e "${RED}✗ .envファイルが見つかりません${NC}"
    exit 1
fi

# 2. compose.yamlの確認
echo -e "${YELLOW}[2/4] compose.yamlの確認...${NC}"
if grep -q "env_file:" "$COMPOSE_DIR/compose.yaml"; then
    echo -e "${GREEN}✓ compose.yamlに env_file ディレクティブが含まれています${NC}"
else
    echo -e "${RED}✗ compose.yamlに env_file ディレクティブが含まれていません${NC}"
    exit 1
fi
echo ""

# 3. Docker Composeの設定を確認（オプション）
echo -e "${YELLOW}[3/4] Docker Compose設定の確認...${NC}"
cd "$COMPOSE_DIR"
if command -v docker &> /dev/null; then
    echo -e "${CYAN}WEBHOOK_URL の展開結果:${NC}"
    docker compose config 2>/dev/null | grep -A2 "WEBHOOK_URL" | head -5
    echo ""
else
    echo -e "${YELLOW}⚠ Docker が見つかりません（スキップ）${NC}"
    echo ""
fi

# 4. 推奨される確認手順
echo -e "${YELLOW}[4/4] 推奨される確認手順...${NC}"
echo -e "${CYAN}n8nコンテナが起動している場合は、以下のコマンドで環境変数を確認できます:${NC}"
echo ""
echo -e "  ${GREEN}docker compose exec n8n printenv WEBHOOK_URL${NC}"
echo -e "  ${GREEN}docker compose exec n8n printenv N8N_HOST${NC}"
echo ""
echo -e "${CYAN}n8n UIで確認:${NC}"
echo -e "  1. n8nにアクセス"
echo -e "  2. ワークフローを開く"
echo -e "  3. Slack Triggerノードをクリック"
echo -e "  4. Webhook URLsセクションを確認"
echo ""
echo -e "${GREEN}=== チェックリスト ===${NC}"
echo -e "  [ ] .envファイルが存在し、ngrok URLが含まれている"
echo -e "  [ ] compose.yamlに env_file: - .env が含まれている"
echo -e "  [ ] docker compose exec n8n printenv WEBHOOK_URL でngrok URLが表示される"
echo -e "  [ ] n8n UIのWebhook URLsに正しいngrok URLが表示される"
echo ""
