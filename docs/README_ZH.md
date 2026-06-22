<p align="center">
  <b>Daily News MCP Server</b><br>
  新闻分类 · 热点新闻 · 热门推文 · 加密情报
</p>

<p align="center">
  <a href="../README.md">English</a> | <a href="./README_JA.md">日本語</a> | <a href="./README_KO.md">한국어</a>
</p>

---

## 快速安装

### Claude Code

```bash
claude mcp add daily-news \
  -- uv --directory /path/to/daily-news run daily-news-mcp
```

> `/path/to/daily-news` 替换为你本地的项目路径。

### OpenClaw

```bash
cp -r openclaw-skill/daily-news ~/.openclaw/skills/6551-daily-news
```

### Hermes Agent

零依赖 skill（仅需 curl），无需 MCP 服务：

```bash
cp -r hermes-skill/daily-news ~/.hermes/skills/research/daily-news
```

在 Hermes 中用 `/daily-news` 调用，或直接询问热点新闻。

---

## 让 AI 帮你审查并安装

不确定这个 MCP 是否安全？把下面这段 prompt 发给你的 AI 助手，让它先审查源码再决定是否安装：

> **复制下方 prompt，粘贴给你的 AI 助手（将 `<项目路径>` 替换为实际值）：**

```text
请帮我审查并安装 daily-news-mcp 这个 MCP server。项目在本地 <项目路径> 目录。

步骤：
1. 审查项目内包括但不限于以下文件的安全性：
   - src/daily_news_mcp/api_client.py — 确认只连接了 ai.6551.io，没有向其他地址发送数据
   - src/daily_news_mcp/config.py — 确认没有硬编码或外泄
   - src/daily_news_mcp/tools.py — 确认所有工具只做 API 查询，没有文件写入、命令执行或其他危险操作
   - pyproject.toml — 确认依赖项只有 mcp、httpx，没有可疑包
2. 告诉我审查结论：安全/有风险/有问题，以及具体理由
3. 如果安全，帮我执行安装：
   claude mcp add daily-news -- uv --directory <项目路径> run daily-news-mcp
```

---

## 它能做什么？

连接后，直接对你的 AI 助手说：

| 你说 | 它做 |
|------|------|
| "查看所有新闻分类" | 获取所有可用分类和子分类 |
| "今天 DeFi 有什么热点？" | 获取 DeFi 分类的热点新闻和推文 |
| "加密市场最新消息" | 获取加密市场分类的热门新闻 |
| "AI 相关的新闻和推文" | 获取 AI 子分类的新闻+推文组合数据 |

---

## 可用工具一览

| 工具 | 说明 |
|------|------|
| `get_news_categories` | 获取所有新闻分类和子分类 |
| `get_hot_news` | 按分类/子分类获取热点新闻和推文 |

---

## 配置

| 变量 | 必需 | 说明 |
|------|------|------|
| `DAILY_NEWS_API_BASE` | 否 | 覆盖 REST API 地址（默认 `https://ai.6551.io`） |
| `DAILY_NEWS_MAX_ROWS` | 否 | 每次查询最大结果数（默认 100） |

也支持项目根目录的 `config.json`（环境变量优先级更高）：

```json
{
  "api_base_url": "https://ai.6551.io",
  "max_rows": 100
}
```

---

<details>
<summary><b>其他客户端 — 手动安装</b>（点击展开）</summary>

> 以下配置中，将 `/path/to/daily-news` 替换为实际项目路径。

### Claude Desktop

编辑配置（macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`）：

```json
{
  "mcpServers": {
    "daily-news": {
      "command": "uv",
      "args": ["--directory", "/path/to/daily-news", "run", "daily-news-mcp"]
    }
  }
}
```

### Cursor

`~/.cursor/mcp.json` 或 Settings > MCP Servers：

```json
{
  "mcpServers": {
    "daily-news": {
      "command": "uv",
      "args": ["--directory", "/path/to/daily-news", "run", "daily-news-mcp"]
    }
  }
}
```

### Windsurf

`~/.codeium/windsurf/mcp_config.json`：

```json
{
  "mcpServers": {
    "daily-news": {
      "command": "uv",
      "args": ["--directory", "/path/to/daily-news", "run", "daily-news-mcp"]
    }
  }
}
```

</details>

---

## 开发

```bash
cd /path/to/daily-news
uv sync
uv run daily-news-mcp
```

```bash
# MCP Inspector 测试
npx @modelcontextprotocol/inspector uv --directory /path/to/daily-news run daily-news-mcp
```

### 项目结构

```
├── README.md                  # English
├── docs/
│   ├── README_ZH.md           # 中文
│   ├── README_JA.md           # 日本語
│   └── README_KO.md           # 한국어
├── openclaw-skill/daily-news/     # OpenClaw Skill
├── pyproject.toml
├── config.json
└── src/daily_news_mcp/
    ├── server.py              # 入口
    ├── app.py                 # FastMCP 实例
    ├── config.py              # 配置加载
    ├── api_client.py          # HTTP 客户端
    └── tools.py               # 2 个工具
```

## 许可证

MIT
