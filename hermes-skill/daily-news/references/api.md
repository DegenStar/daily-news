# 6551 News API Reference

Full reference for the two public endpoints used by this skill. No
authentication is required for either.

**Base URL**: `https://ai.6551.io`

---

## GET /open/free_categories

Returns all available news categories and their subcategories.

**Parameters**: none

**Response**

```json
{
  "categories": [
    {
      "key": "web3",
      "name": "Web3 & Crypto",
      "name_zh": "Web3与加密货币",
      "description": "Cryptocurrency, blockchain, DeFi, NFT, and Web3 ecosystem",
      "subcategories": [
        {
          "key": "defi",
          "name": "DeFi & Infrastructure",
          "name_zh": "DeFi与基础设施",
          "description": "DeFi protocols, L1/L2 chains, exchanges, stablecoins, ETFs"
        }
      ]
    }
  ]
}
```

### Known categories (verified 2026-06-23)

| `key`   | name              | subcategory `key`s                          |
|---------|-------------------|---------------------------------------------|
| `web3`  | Web3 & Crypto     | `defi`, `meme`, `nft_gamefi`, `regulation`  |
| `ai`    | AI & Technology   | `crypto_ai`, `models`, `chips`              |
| `macro` | Macro Finance     | `markets`, `fed`, `geopolitics`             |

The list is dynamic; always trust a live `free_categories` call over this table.

---

## GET /open/free_hot

Returns hot news articles and trending tweets for a category.

**Parameters**

| Parameter     | Type   | Required | Description                                   |
|---------------|--------|----------|-----------------------------------------------|
| `category`    | string | Yes      | Category `key` from `free_categories`         |
| `subcategory` | string | No       | Subcategory `key`; omit for the whole category|

**Response**

```json
{
  "success": true,
  "category": "web3",
  "subcategory": "defi",
  "news": {
    "success": true,
    "count": 50,
    "items": [
      {
        "id": 123,
        "title": "...",
        "source": "...",
        "link": "https://...",
        "score": 85,
        "grade": "A",
        "signal": "long",
        "summary_zh": "...",
        "summary_en": "...",
        "coins": ["BTC", "ETH"],
        "engine_type": "...",
        "published_at": "2026-06-23T10:00:00Z",
        "created_at": "2026-06-23T10:05:00Z"
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
        "posted_at": "2026-06-23T09:00:00Z",
        "relevance": "high"
      }
    ]
  }
}
```

### News item fields

| Field          | Type         | Notes                                            |
|----------------|--------------|--------------------------------------------------|
| `id`           | int          | Stable item id                                   |
| `title`        | string       | Headline                                         |
| `source`       | string       | Publisher / outlet                               |
| `link`         | string (URL) | Full article                                     |
| `score`        | int (0–100)  | Hotness/importance; higher = more prominent      |
| `grade`        | string       | Quality grade, e.g. `A+`, `A`, `B`               |
| `signal`       | string       | `long` \| `short` \| `neutral`                   |
| `summary_en`   | string       | English summary (no full body)                   |
| `summary_zh`   | string       | 中文摘要                                          |
| `coins`        | string[]     | Mentioned tickers, e.g. `["BTC","ETH"]`          |
| `engine_type`  | string       | Internal source/engine tag                       |
| `published_at` | string (ISO) | Original publish time (UTC)                       |
| `created_at`   | string (ISO) | Ingestion time (UTC)                             |

### Tweet item fields

| Field       | Type         | Notes                                  |
|-------------|--------------|----------------------------------------|
| `author`    | string       | Display name                           |
| `handle`    | string       | @handle (without `@`)                  |
| `content`   | string       | Tweet text                             |
| `url`       | string (URL) | Link to tweet                          |
| `metrics`   | object       | `{ likes, retweets, replies }`         |
| `posted_at` | string (ISO) | Post time (UTC)                        |
| `relevance` | string       | `high` \| `medium` \| `low`            |

`tweets.count` may be `0` for some categories — that is normal.

---

## Errors & behavior

- `200` — success.
- `503` — data for that category is still being generated; retry after a short wait.
- Other 4xx/5xx — treat as transient unless repeated; surface the status to the user.
- Data is a periodically-refreshed cache of *current* hot items, not a searchable archive.
