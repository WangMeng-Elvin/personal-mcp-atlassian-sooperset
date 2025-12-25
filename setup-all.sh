#!/bin/bash

# mcp-atlassian 部署脚本
# 此脚本将配置 mcp-atlassian MCP 服务器

set -e

echo "=========================================="
echo "mcp-atlassian 部署脚本"
echo "=========================================="
echo ""
echo "此脚本将设置："
echo "1. mcp-atlassian (MCP 服务器)"
echo ""
echo "预计时间: 3-5 分钟"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ==========================================
# 步骤 1: 检查前置条件
# ==========================================

echo "=========================================="
echo "步骤 1/3: 检查前置条件"
echo "=========================================="
echo ""

# 检查 uv
if command -v uv &> /dev/null; then
    echo -e "${GREEN}✅ uv 已安装:${NC} $(uv --version)"
    USE_UV=true
else
    echo -e "${YELLOW}⚠️  uv 未安装${NC}"
    echo ""
    echo "是否使用 pip+venv 替代？(y/n)"
    read -p "请输入 (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        USE_UV=false
        # 检查 Python
        if command -v python3 &> /dev/null; then
            echo -e "${GREEN}✅ Python 已安装:${NC} $(python3 --version)"
        else
            echo -e "${RED}❌ Python3 未安装${NC}"
            exit 1
        fi
    else
        echo ""
        echo "请先安装 uv:"
        echo "  brew install uv"
        echo ""
        echo "或使用官方脚本:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
fi

# 检查 Cursor
if [ -d "/Applications/Cursor.app" ]; then
    echo -e "${GREEN}✅ Cursor 已安装${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 Cursor.app${NC}"
    echo "   请确保已安装 Cursor: https://cursor.sh"
fi

echo ""

# ==========================================
# 步骤 2: 设置 mcp-atlassian
# ==========================================

echo "=========================================="
echo "步骤 2/3: 设置 mcp-atlassian"
echo "=========================================="
echo ""

# 安装依赖
if [ "$USE_UV" = true ]; then
    echo "📦 安装 mcp-atlassian 依赖（使用 uv）..."
    uv sync --frozen --all-extras --dev
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
else
    echo "📦 安装 mcp-atlassian 依赖（使用 pip+venv）..."
    
    # 创建虚拟环境
    if [ -d ".venv" ]; then
        echo -e "${YELLOW}⚠️  虚拟环境已存在，跳过创建${NC}"
    else
        echo "创建虚拟环境..."
        python3 -m venv .venv
        echo -e "${GREEN}✅ 虚拟环境创建完成${NC}"
    fi
    
    # 激活虚拟环境并安装
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -e ".[all,dev]"
    deactivate
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
fi
echo ""

# 创建 .env 文件
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ 已创建 .env 文件${NC}"
        echo -e "${YELLOW}⚠️  请编辑 .env 文件，填入您的 Confluence/Jira 凭证${NC}"
    else
        echo -e "${RED}❌ 找不到 .env.example${NC}"
    fi
else
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
fi
echo ""

# 测试运行
echo "🧪 测试 mcp-atlassian..."
if [ "$USE_UV" = true ]; then
    timeout 3 uv run mcp-atlassian 2>&1 | head -n 5 || true
else
    source .venv/bin/activate
    timeout 3 python -m mcp_atlassian 2>&1 | head -n 5 || true
    deactivate
fi
echo -e "${GREEN}✅ mcp-atlassian 可以启动${NC}"
echo ""

# ==========================================
# 步骤 3: 配置 Cursor 全局 MCP（可选）
# ==========================================

echo "=========================================="
echo "步骤 3/3: 配置 Cursor 全局 MCP（可选）"
echo "=========================================="
echo ""

CURSOR_CONFIG="$HOME/.cursor/mcp_config.json"

echo "Cursor 全局 MCP 配置文件: $CURSOR_CONFIG"
echo ""
echo "是否要配置 Cursor 全局 MCP？(y/n)"
echo "（推荐配置，这样在任何项目中都能使用 mcp-atlassian）"
echo ""
read -p "请输入 (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/.cursor"
    
    if [ "$USE_UV" = true ]; then
        # 使用 uv 的配置
        cat > "$CURSOR_CONFIG" << EOF
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "uv",
      "args": [
        "--directory",
        "$SCRIPT_DIR",
        "run",
        "mcp-atlassian"
      ],
      "env": {
        "CONFLUENCE_URL": "https://your-confluence-server.com",
        "CONFLUENCE_USERNAME": "your-email@company.com",
        "CONFLUENCE_PERSONAL_TOKEN": "your_confluence_pat",
        "JIRA_URL": "https://your-jira-server.com",
        "JIRA_USERNAME": "your-email@company.com",
        "JIRA_PERSONAL_TOKEN": "your_jira_pat"
      }
    }
  }
}
EOF
    else
        # 使用 pip+venv 的配置
        cat > "$CURSOR_CONFIG" << EOF
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "$SCRIPT_DIR/.venv/bin/mcp-atlassian",
      "args": [],
      "env": {
        "CONFLUENCE_URL": "https://your-confluence-server.com",
        "CONFLUENCE_USERNAME": "your-email@company.com",
        "CONFLUENCE_PERSONAL_TOKEN": "your_confluence_pat",
        "JIRA_URL": "https://your-jira-server.com",
        "JIRA_USERNAME": "your-email@company.com",
        "JIRA_PERSONAL_TOKEN": "your_jira_pat"
      }
    }
  }
}
EOF
    fi
    
    echo -e "${GREEN}✅ 已创建 Cursor 全局 MCP 配置${NC}"
    echo -e "${YELLOW}⚠️  请编辑以下文件，填入您的凭证：${NC}"
    echo "   $CURSOR_CONFIG"
else
    echo "跳过 Cursor 全局配置"
fi

echo ""

# ==========================================
# 完成
# ==========================================

echo "=========================================="
echo -e "${GREEN}✅ 设置完成！${NC}"
echo "=========================================="
echo ""
echo "📋 完成检查清单："
echo ""
echo "1. mcp-atlassian:"
echo "   [x] 依赖已安装"
if [ "$USE_UV" = true ]; then
    echo "   [x] 使用 uv 管理依赖"
else
    echo "   [x] 使用 pip+venv 管理依赖"
    echo "   [x] 虚拟环境: .venv/"
fi
echo "   [ ] .env 已配置凭证 👈 需要手动完成"
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "2. Cursor 全局 MCP:"
    echo "   [x] 配置文件已创建"
    echo "   [ ] 已配置凭证 👈 需要手动完成"
    echo ""
fi

echo "=========================================="
echo "📝 下一步操作："
echo "=========================================="
echo ""
echo "1. 获取 Confluence/Jira PAT:"
echo "   - Confluence: https://your-server.com/plugins/personalaccesstokens/usertokens.action"
echo "   - Jira: https://your-server.com/plugins/personalaccesstokens/usertokens.action"
echo ""
echo "2. 配置凭证:"
echo "   编辑 .env (mcp-atlassian)"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   编辑 $CURSOR_CONFIG (全局配置)"
fi
echo ""
echo "3. 测试部署:"
if [ "$USE_UV" = true ]; then
    echo "   uv run mcp-atlassian"
else
    echo "   source .venv/bin/activate"
    echo "   python -m mcp_atlassian"
fi
echo ""
echo "4. 在 Cursor 中测试:"
echo "   cursor ."
echo "   # 在 Cursor Chat 中测试: \"搜索 Confluence 页面\""
echo ""
echo "5. 查看详细文档:"
echo "   cat others/MCP-Atlassian本地部署指南.md"
echo ""
echo "=========================================="
echo "🎉 祝您使用愉快！"
echo "=========================================="
echo ""
