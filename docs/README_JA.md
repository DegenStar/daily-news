<p align="center">
  <b>Daily News MCP Server</b><br>
  ニュースカテゴリ · ホットニュース · トレンドツイート · 暗号資産インテリジェンス
</p>

<p align="center">
  <a href="../README.md">English</a> | <a href="./README_ZH.md">中文</a> | <a href="./README_KO.md">한국어</a>
</p>

---

## クイックインストール

### Claude Code

```bash
claude mcp add daily-news \
  -- uv --directory /path/to/daily-news run daily-news-mcp
```

> `/path/to/daily-news` をローカルのプロジェクトパスに置き換えてください。

### OpenClaw

```bash
cp -r openclaw-skill/daily-news ~/.openclaw/skills/6551-daily-news
```

### Hermes Agent

依存関係ゼロの skill（curl のみ）。MCP サーバーは不要です：

```bash
cp -r hermes-skill/daily-news ~/.hermes/skills/research/daily-news
```

Hermes では `/daily-news` で呼び出すか、ホットニュースを直接尋ねてください。

---

## AI にレビュー＆インストールしてもらう

この MCP が安全かどうか不安ですか？以下のプロンプトを AI アシスタントに送信すれば、ソースコードをレビューしてからインストールしてくれます：

> **以下のプロンプトをコピーして AI アシスタントに送信してください（`<プロジェクトパス>` を実際の値に置き換え）：**

```text
daily-news-mcp という MCP サーバーをレビューしてインストールしてください。プロジェクトはローカルの <プロジェクトパス> にあります。

手順：
1. 以下のファイルのセキュリティを確認：
   - src/daily_news_mcp/api_client.py — ai.6551.io のみに接続し、他のアドレスにデータを送信していないことを確認
   - src/daily_news_mcp/config.py — ハードコードや漏洩がないことを確認
   - src/daily_news_mcp/tools.py — すべてのツールが API クエリのみを実行し、ファイル書き込み、コマンド実行、その他の危険な操作がないことを確認
   - pyproject.toml — 依存関係が mcp、httpx のみで、不審なパッケージがないことを確認
2. レビュー結論を教えてください：安全 / リスクあり / 問題あり、具体的な理由とともに
3. 安全であれば、インストールを実行：
   claude mcp add daily-news -- uv --directory <プロジェクトパス> run daily-news-mcp
```

---

## 何ができる？

接続後、AI アシスタントに話しかけるだけ：

| あなたが言う | 実行される操作 |
|-------------|---------------|
| 「すべてのニュースカテゴリを見せて」 | 利用可能なカテゴリとサブカテゴリを一覧表示 |
| 「今日の DeFi のホットニュースは？」 | DeFi カテゴリのホットニュースとツイートを取得 |
| 「暗号資産市場の最新ニュース」 | 暗号資産市場カテゴリのトレンドニュースを取得 |
| 「AI 関連のニュースとツイート」 | AI サブカテゴリのニュース＋ツイートを取得 |

---

## 利用可能なツール

| ツール | 説明 |
|--------|------|
| `get_news_categories` | すべてのニュースカテゴリとサブカテゴリを取得 |
| `get_hot_news` | カテゴリ/サブカテゴリ別にホットニュースとツイートを取得 |

---

## 設定

| 変数 | 必須 | 説明 |
|------|------|------|
| `DAILY_NEWS_API_BASE` | いいえ | REST API URL のオーバーライド（デフォルト: `https://ai.6551.io`） |
| `DAILY_NEWS_MAX_ROWS` | いいえ | クエリあたりの最大結果数（デフォルト: 100） |

プロジェクトルートの `config.json` もサポート（環境変数が優先）：

```json
{
  "api_base_url": "https://ai.6551.io",
  "max_rows": 100
}
```

---

## 開発

```bash
cd /path/to/daily-news
uv sync
uv run daily-news-mcp
```

```bash
# MCP Inspector
npx @modelcontextprotocol/inspector uv --directory /path/to/daily-news run daily-news-mcp
```

### プロジェクト構造

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
    ├── server.py              # エントリポイント
    ├── app.py                 # FastMCP インスタンス
    ├── config.py              # 設定ローダー
    ├── api_client.py          # HTTP クライアント
    └── tools.py               # 2 ツール
```

## ライセンス

MIT
