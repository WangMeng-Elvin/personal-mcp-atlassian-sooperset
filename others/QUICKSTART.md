# 快速开始指南

> 10 分钟完成 mcp-atlassian 部署

## 概述

本指南将帮助您快速部署和使用 mcp-atlassian MCP 服务器，在 Cursor 中访问 Confluence 和 Jira。

---

## 前置条件

确保已安装：
- ✅ macOS
- ✅ Python 3.10+
- ✅ Cursor IDE

---

## 选择部署方式

### 方式 1: 使用 uv（推荐 - 更快）

**优点**: ⚡️ 速度快 10 倍，自动管理虚拟环境

```bash
# 安装 uv（如果还没有）
brew install uv

# 运行自动设置脚本
./setup-all.sh
```

### 方式 2: 使用 pip+venv（传统方式）

**优点**: ✅ 无需安装新工具，团队可能已熟悉

```bash
# 无需额外安装，Python 自带 pip 和 venv

# 运行设置脚本（会自动检测并使用 pip+venv）
./setup-all.sh
```

**详细对比**: 查看 [`部署方式对比.md`](./部署方式对比.md)

---

## 快速部署（推荐）

### 步骤 1: 运行自动设置脚本

```bash
cd /Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset

# 使用 uv（推荐）
./setup-all.sh

# 脚本会自动检测 uv，如果没有则使用 pip+venv
```

这个脚本会：
1. ✅ 检查 uv 是否安装（如未安装会提示使用 pip+venv）
2. ✅ 安装 mcp-atlassian 依赖
3. ✅ 创建必要的配置文件
4. ✅ （可选）配置 Cursor 全局 MCP

### 步骤 2: 获取 PAT（Personal Access Token）

#### Confluence PAT:
1. 访问: `https://your-confluence-server.com/plugins/personalaccesstokens/usertokens.action`
2. 点击 "Create token"
3. 保存生成的 token

#### Jira PAT:
1. 访问: `https://your-jira-server.com/plugins/personalaccesstokens/usertokens.action`
2. 点击 "Create token"
3. 保存生成的 token

### 步骤 3: 配置凭证

编辑 `.env` 文件：

```bash
nano .env
```

填入：
```bash
CONFLUENCE_URL=https://your-confluence-server.com
CONFLUENCE_USERNAME=your-email@company.com
CONFLUENCE_PERSONAL_TOKEN=your_confluence_pat_here

JIRA_URL=https://your-jira-server.com
JIRA_USERNAME=your-email@company.com
JIRA_PERSONAL_TOKEN=your_jira_pat_here

MCP_LOGGING_STDOUT=true
READ_ONLY_MODE=false
```

### 步骤 4: 测试部署

#### 测试 mcp-atlassian

```bash
cd /Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset

# 使用 uv
uv run mcp-atlassian

# 或使用 pip+venv
source .venv/bin/activate
python -m mcp_atlassian
```

看到服务器启动消息即成功（Ctrl+C 停止）。

#### 在 Cursor 中测试

```bash
cd /Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset
cursor .
```

在 Cursor Chat 中输入：
```
搜索 Confluence 中标题包含 "test" 的页面
```

或

```
获取 Jira issue PROJ-123 的详细信息
```

---

## 手动部署（如果自动脚本失败）

### 1. 安装 uv（可选）

```bash
brew install uv
```

### 2. 设置 mcp-atlassian

#### 使用 uv:

```bash
cd /Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset

# 安装依赖
uv sync --frozen --all-extras --dev

# 创建配置
cp .env.example .env
nano .env  # 填入凭证
```

#### 使用 pip+venv:

```bash
cd /Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset

# 创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install --upgrade pip
pip install -e ".[all,dev]"

# 创建配置
cp .env.example .env
nano .env  # 填入凭证
```

### 3. 配置 Cursor MCP（可选）

编辑 `~/.cursor/mcp_config.json`：

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset",
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
```

如果使用 pip+venv，改为：

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "/Users/meng.c.wang/Documents/GitHub_Personal/personal-mcp-atlassian-sooperset/.venv/bin/mcp-atlassian",
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
```

---

## 实际使用示例

### 示例 1: 搜索 Confluence 页面

在 Cursor Chat 中：
```
在 PIB 空间中搜索标题包含 "API" 的页面
```

### 示例 2: 获取页面内容

```
获取 Confluence 页面 6325835121 的内容
```

### 示例 3: 分析页面

```
分析 Confluence 页面 123456789，包括：
1. 内容质量（清晰度、完整性）
2. 结构合理性
3. 可能的改进建议
```

### 示例 4: 搜索和总结 Jira Issues

```
搜索项目 MYPROJ 中所有状态为 "In Progress" 的 issues，并总结主要工作内容
```

### 示例 5: 创建内容

```
在 PIB 空间中创建一个新的 Confluence 页面，标题为 "API 设计指南"
```

---

## 常见问题

### Q: 我不想用 uv，可以用 pip 吗？

**可以！** 运行 `./setup-all.sh`，脚本会自动检测并使用 pip+venv。

### Q: uv 命令找不到？

```bash
# 方式 1: 使用 pip+venv 替代
./setup-all.sh  # 脚本会自动使用 pip+venv

# 方式 2: 安装 uv
brew install uv
source ~/.zshrc
```

### Q: MCP 连接失败？

```bash
# 检查 mcp-atlassian 是否能运行
cd /path/to/mcp-atlassian
uv run mcp-atlassian
# 或
source .venv/bin/activate
python -m mcp_atlassian

# 检查配置文件路径是否正确
cat ~/.cursor/mcp_config.json | grep directory

# 重启 Cursor
killall Cursor && open -a Cursor
```

### Q: 认证失败？

```bash
# 测试 PAT
curl -u "your-email@company.com:your_pat" \
  https://your-confluence-server.com/rest/api/content?limit=1

# 检查 .env 中的凭证
```

---

## 下一步

1. ✅ **阅读详细文档**
   - `MCP-Atlassian本地部署指南.md` - 完整部署流程
   - `常见问题解答.md` - FAQ
   - `部署方式对比.md` - uv vs pip+venv

2. ✅ **熟悉功能**
   - 尝试搜索 Confluence 页面
   - 尝试获取 Jira issue
   - 尝试创建和更新内容

3. ✅ **自定义工作流**
   - 在 Cursor 中创建自定义提示词
   - 配置批量操作脚本

---

## 获取帮助

- 📖 详细文档：`others/` 目录
- 🐛 问题排查：`MCP-Atlassian本地部署指南.md` → 故障排查章节
- 💬 GitHub Issues：提交问题和建议

---

## 文件结构

```
.
├── setup-all.sh                ← 自动设置脚本
├── .env                        ← mcp-atlassian 配置
├── .env.example                ← 配置模板
├── pyproject.toml              ← Python 项目配置
├── uv.lock                     ← 依赖锁定（如果使用 uv）
├── .venv/                      ← 虚拟环境（如果使用 pip+venv）
└── others/                     ← 详细文档
    ├── QUICKSTART.md           ← 本文档
    ├── MCP-Atlassian本地部署指南.md
    ├── 常见问题解答.md
    ├── 部署方式对比.md
    └── README.md
```

---

**预计时间**: 
- 自动部署：5-10 分钟
- 手动部署：15-20 分钟

**难度**: ⭐⭐☆☆☆（简单）

祝您使用愉快！🎉
