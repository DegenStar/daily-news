<p align="center">
  <b>Daily News MCP Server</b><br>
  News Categories · Hot News · Trending Tweets · Crypto Intelligence
</p>

<p align="center">
  <a href="./docs/README_ZH.md">中文</a> | <a href="./docs/README_JA.md">日本語</a> | <a href="./docs/README_KO.md">한국어</a>
</p>

---

## Quick Install

### Claude Code

```bash
claude mcp add daily-news \
  -- uv --directory /path/to/daily-news run daily-news-mcp
```

> Replace `/path/to/daily-news` with your local project path.

### OpenClaw

```bash
cp -r openclaw-skill/daily-news ~/.openclaw/skills/6551-daily-news
```

### Hermes Agent

Zero-dependency skill (curl only), no MCP server needed:

```bash
cp -r hermes-skill/daily-news ~/.hermes/skills/research/daily-news
```

Then invoke it in Hermes with `/daily-news` or just ask for hot news.

---

## Let AI Review & Install For You

Not sure if this MCP is safe? Paste the prompt below to your AI assistant — it will review the source code first, then install if safe:

> **Copy this prompt and send it to your AI assistant (replace `<project-path>` with actual value):**

```text
Please review and install the daily-news-mcp MCP server for me. The project is at <project-path>.

Steps:
1. Review these files for security:
   - src/daily_news_mcp/api_client.py — Confirm it only connects to ai.6551.io, no data sent elsewhere
   - src/daily_news_mcp/config.py — Confirm no hardcoded secrets or leaks
   - src/daily_news_mcp/tools.py — Confirm all tools only perform API queries, no file writes, command execution, or dangerous operations
   - pyproject.toml — Confirm dependencies are only mcp, httpx, no suspicious packages
2. Tell me your conclusion: safe / risky / problematic, with specific reasons
3. If safe, run the install:
   claude mcp add daily-news -- uv --directory <project-path> run daily-news-mcp
```

---

## What Can It Do?

Once connected, just ask your AI assistant:

| You say | It does |
|---------|---------|
| "Show me all news categories" | List all available categories and subcategories |
| "What's hot in DeFi today?" | Get hot news and tweets for the DeFi category |
| "Get crypto market news" | Fetch trending news for the crypto market category |
| "Show me AI-related news and tweets" | Get combined news + tweets for AI subcategory |

---

## Available Tools

| Tool | Description |
|------|-------------|
| `get_news_categories` | Get all available news categories and subcategories |
| `get_hot_news` | Get hot news and tweets by category/subcategory |

---

## Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `DAILY_NEWS_API_BASE` | No | Override REST API URL (default: `https://ai.6551.io`) |
| `DAILY_NEWS_MAX_ROWS` | No | Max results per query (default: 100) |

Also supports `config.json` in the project root (env vars take precedence):

```json
{
  "api_base_url": "https://ai.6551.io",
  "max_rows": 100
}
```

---

## API Endpoints

| Endpoint | Method | Parameters | Description |
|----------|--------|------------|-------------|
| `/open/free_categories` | GET | — | Get all news categories |
| `/open/free_hot` | GET | `category`, `subcategory` | Get hot news + tweets |

### Response: free_categories

```json
[
  {
    "key": "crypto",
    "name": "Crypto",
    "name_zh": "加密货币",
    "description": "...",
    "subcategories": [
      {
        "key": "defi",
        "name": "DeFi",
        "name_zh": "去中心化金融",
        "description": "..."
      }
    ]
  }
]
```

### Response: free_hot

```json
{
  "success": true,
  "category": "crypto",
  "subcategory": "defi",
  "news": {
    "success": true,
    "count": 10,
    "items": [
      {
        "id": 123,
        "title": "...",
        "source": "...",
        "link": "https://...",
        "score": 85,
        "grade": "A",
        "signal": "bullish",
        "summary_zh": "...",
        "summary_en": "...",
        "coins": ["BTC", "ETH"],
        "published_at": "2026-03-17T10:00:00Z"
      }
    ]
  },
  "tweets": {
    "success": true,
    "count": 5,
    "items": [
      {
        "author": "Vitalik Buterin",
        "handle": "VitalikButerin",
        "content": "...",
        "url": "https://...",
        "metrics": { "likes": 1000, "retweets": 200, "replies": 50 },
        "posted_at": "2026-03-17T09:00:00Z",
        "relevance": "high"
      }
    ]
  }
}
```

---

<details>
<summary><b>Other Clients — Manual Install</b> (click to expand)</summary>

> In all configs below, replace `/path/to/daily-news` with your actual local project path.

### Claude Desktop

Edit config (macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`, Windows: `%APPDATA%\Claude\claude_desktop_config.json`):

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

`~/.cursor/mcp.json` or Settings > MCP Servers:

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

`~/.codeium/windsurf/mcp_config.json`:

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

## Supported Clients

| Client | Config | Status |
|--------|--------|--------|
| Claude Code | CLI | Supported |
| Claude Desktop | JSON config | Supported |
| Cursor | JSON config | Supported |
| Windsurf | JSON config | Supported |
| Cherry Studio | GUI | Supported |
| Zed | JSON config | Supported |
| Hermes Agent | SKILL.md (curl) | Supported |
| OpenClaw | SKILL.md | Supported |

---

## Development

```bash
cd /path/to/daily-news
uv sync
uv run daily-news-mcp
```

```bash
# MCP Inspector
npx @modelcontextprotocol/inspector uv --directory /path/to/daily-news run daily-news-mcp
```

### Project Structure

```
├── README.md                  # English
├── docs/
│   ├── README_ZH.md           # 中文
│   ├── README_JA.md           # 日本語
│   └── README_KO.md           # 한국어
├── openclaw-skill/daily-news/     # OpenClaw Skill
├── hermes-skill/daily-news/       # Hermes Agent Skill (curl-only)
│   ├── SKILL.md
│   └── references/api.md
├── pyproject.toml
├── config.json
└── src/daily_news_mcp/
    ├── server.py              # Entry point
    ├── app.py                 # FastMCP instance
    ├── config.py              # Config loader
    ├── api_client.py          # HTTP client
    └── tools.py               # 2 tools
```

## License

MIT
