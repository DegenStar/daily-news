---
name: daily-news
description: Use when the user asks for daily news, hot topics, market sentiment, or trending tweets in crypto/Web3, AI/technology, or macro/markets. Fetches categorized hot news and tweets from the 6551 public REST API with no authentication required.
version: 1.0.0
author: DegenStar
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [news, crypto, web3, ai, macro, sentiment]
    category: research
---

# Daily News

## Overview

Query daily news and hot topics from the 6551 platform via two public REST
endpoints. Every item carries a quality grade, a sentiment signal, bilingual
(EN/ZH) summaries, and (for crypto items) the coins it mentions — so you can
rank, filter, and summarize without extra processing.

- **Base URL**: `https://ai.6551.io`
- **Auth**: none
- **Dependencies**: `curl` only (`jq` optional, for prettier filtering)

## When to Use

Use this skill when the user asks for:

- "What's hot in DeFi / crypto / AI today?"
- "Show me the top news on the Fed / markets / geopolitics"
- "Any trending tweets about meme coins?"
- "Give me a market sentiment read for Web3"

**Do not use** for: historical/archival search, full-text article bodies (only
summaries are returned), or anything requiring a login. The data is a cached
snapshot of *current* hot items, refreshed periodically.

## Categories

Three top-level categories, each with subcategories. Pass the `key` (left
column), never the display name.

| Category `key` | Subcategory `key`s |
|----------------|--------------------|
| `web3` (Web3 & Crypto) | `defi`, `meme`, `nft_gamefi`, `regulation` |
| `ai` (AI & Technology) | `crypto_ai`, `models`, `chips` |
| `macro` (Macro Finance) | `markets`, `fed`, `geopolitics` |

To confirm the live list (it can change), call `free_categories` first — see
below. The full schema is in [references/api.md](references/api.md).

## Procedure

### 1. List categories

Run this when you are unsure which `key` to use, or to show the user what's
available:

```bash
curl -s "https://ai.6551.io/open/free_categories"
```

Returns `{ "categories": [ { key, name, name_zh, description, subcategories:[…] } ] }`.

### 2. Get hot news + tweets

```bash
# Whole category
curl -s "https://ai.6551.io/open/free_hot?category=web3"

# Narrow to a subcategory
curl -s "https://ai.6551.io/open/free_hot?category=web3&subcategory=defi"
```

`category` is **required**; `subcategory` is optional. Returns a `news` block
and a `tweets` block, each with `count` and `items`.

Each **news** item: `title`, `source`, `link`, `score` (0–100), `grade`
(e.g. `A+`, `A`, `B`), `signal` (`long`/`short`/`neutral`), `summary_en`,
`summary_zh`, `coins` (e.g. `["BTC","ETH"]`), `published_at`.

Each **tweet** item: `author`, `handle`, `content`, `url`, `metrics`
(likes/retweets/replies), `posted_at`, `relevance`.

### 3. Filter / rank (optional, with jq)

```bash
# Top 5 news by score, title + signal only
curl -s "https://ai.6551.io/open/free_hot?category=web3&subcategory=defi" \
  | jq -r '.news.items | sort_by(-.score) | .[:5][] | "\(.score) [\(.signal)] \(.title)"'

# Only long-signal items mentioning BTC
curl -s "https://ai.6551.io/open/free_hot?category=web3" \
  | jq '.news.items[] | select(.signal=="long" and (.coins // [] | index("BTC")))'
```

When summarizing for the user, lead with grade-A / high-score items, group by
`signal`, and cite the `source` and `link`.

## One-Shot Recipes

A bundled helper does steps 2–3 in one call — fetch, sort by score, and print a
readable digest. Requires `curl` + `jq`:

```bash
# List available categories
scripts/hotnews.sh

# Top 5 DeFi items, formatted
scripts/hotnews.sh web3 defi 5

# Top 10 macro/fed items (default limit)
scripts/hotnews.sh macro fed
```

Output lines look like `[score|grade|signal] title` followed by source, coins,
and link. Use it when the user just wants a quick digest; fall back to raw
`curl` + `jq` when they need fields the script doesn't print.

## Common Pitfalls

- **Passing a display name instead of a `key`** — use `web3`, not `Web3 & Crypto`.
- **Omitting `category`** — `free_hot` requires it; there is no "all" mode.
- **Expecting full article text** — only `summary_en` / `summary_zh` are returned; link out for the full piece.
- **`503` response** — data is still being generated for that category; wait and retry, don't treat it as a hard error.
- **Empty `tweets`** — normal for some categories (`count: 0`); fall back to the `news` block.

## Verification

```bash
# Should print 200
curl -s -o /dev/null -w "%{http_code}\n" "https://ai.6551.io/open/free_categories"

# Should print a non-zero news count
curl -s "https://ai.6551.io/open/free_hot?category=web3" | jq '.news.count'
```
