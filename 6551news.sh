#!/usr/bin/env bash
# =============================================================================
# news.sh — 每日热点新闻查询脚本
# =============================================================================
#
# 功能说明:
#   通过 6551 平台 REST API 获取加密/AI/宏观市场的实时热点新闻和推文。
#   完全不经过任何 AI/LLM,零 token 消耗。
#   唯一依赖:curl(必须) + jq(可选,无 jq 时降级输出原始 JSON)
#
# 数据来源:
#   API 地址: https://ai.6551.io
#   接口1: GET /open/free_categories  — 获取所有新闻分类
#   接口2: GET /open/free_hot         — 按分类获取热点新闻和推文
#
# 支持的分类(category / subcategory):
#   web3   — Web3与加密货币  子类: defi, meme, nft_gamefi, regulation
#   ai     — 人工智能与科技  子类: crypto_ai, models, chips
#   macro  — 宏观金融        子类: markets, fed, geopolitics
#
# 输出字段说明:
#   [score|grade|signal]  得分(0-100) | 质量等级(A+/A/B) | 方向(long/short/neutral)
#   Source                新闻来源
#   Coins                 相关代币(如有)
#   Link                  原文链接
#   Tldr                  新闻摘要(中文或英文,由 DAILY_NEWS_LANG 控制)
#
# 用法:
#   ./news.sh                            列出所有可用分类
#   ./news.sh <category>                 显示该分类 top 10 新闻
#   ./news.sh <category> <sub>           显示子分类 top 10 新闻
#   ./news.sh <category> [sub] <N>       显示 top N 条新闻(N 为正整数)
#   ./news.sh -t <category> [sub] [N]    同上,并额外显示热门推文
#
# 示例:
#   ./news.sh                            # 列出 web3 / ai / macro 等分类
#   ./news.sh web3                       # Web3 热点新闻 top 10
#   ./news.sh web3 defi 5                # DeFi 子类 top 5
#   ./news.sh -t ai models               # AI 模型新闻 + 推文
#   ./news.sh macro fed 3                # 美联储相关新闻 top 3
#   DAILY_NEWS_LANG=zh ./news.sh web3    # 显示中文摘要
#
# 环境变量:
#   DAILY_NEWS_API_BASE   覆盖 API 地址(默认: https://ai.6551.io)
#   DAILY_NEWS_LANG       摘要语言: en(默认,英文) 或 zh(中文)
#
set -euo pipefail

BASE_URL="${DAILY_NEWS_API_BASE:-https://ai.6551.io}"
LANG_PREF="${DAILY_NEWS_LANG:-en}"
HAS_JQ=0
command -v jq >/dev/null 2>&1 && HAS_JQ=1

err()  { printf '\033[31merror:\033[0m %s\n' "$1" >&2; exit 1; }
info() { printf '\033[2m%s\033[0m\n' "$1"; }

command -v curl >/dev/null 2>&1 || err "curl is required"

# ---------- parse flags ----------
SHOW_TWEETS=0
if [[ "${1:-}" == "-t" ]]; then
  SHOW_TWEETS=1
  shift
fi

category="${1:-}"
subcategory=""
limit=10

# Positional args after category: could be sub + limit, or just limit, or just sub.
if [[ $# -ge 2 ]]; then
  arg2="${2:-}"
  if [[ "$arg2" =~ ^[0-9]+$ ]]; then
    limit="$arg2"
  else
    subcategory="$arg2"
    if [[ $# -ge 3 ]]; then
      [[ "${3}" =~ ^[0-9]+$ ]] || err "third argument must be a positive integer (limit), got: ${3}"
      limit="${3}"
    fi
  fi
fi

[[ "$limit" =~ ^[0-9]+$ && "$limit" -gt 0 ]] || err "limit must be a positive integer"

# ---------- list categories ----------
list_categories() {
  local raw
  raw="$(curl -fsS --max-time 20 "${BASE_URL}/open/free_categories")" \
    || err "failed to fetch categories (check your connection)"

  if [[ "$HAS_JQ" -eq 1 ]]; then
    printf '\nAvailable categories:\n\n'
    jq -r '.categories[]
      | "  \(.key)\t\(.name)"
        + "\n    └─ subcategories: \([.subcategories[].key] | join("  "))\n"' <<<"$raw"
    printf 'Usage: ./news.sh [-t] <category> [subcategory] [limit]\n\n'
  else
    printf '%s\n' "$raw"
    info "(install jq for formatted output)"
  fi
}

# ---------- no category → list and exit ----------
if [[ -z "$category" ]]; then
  list_categories
  exit 0
fi

# ---------- build URL ----------
url="${BASE_URL}/open/free_hot?category=${category}"
[[ -n "$subcategory" ]] && url="${url}&subcategory=${subcategory}"

# ---------- fetch ----------
resp="$(curl -fsS --max-time 30 "$url")" \
  || err "request failed — the category may still be generating data, retry shortly"

# ---------- raw fallback (no jq) ----------
if [[ "$HAS_JQ" -eq 0 ]]; then
  printf '%s\n' "$resp"
  info "(install jq for formatted output)"
  exit 0
fi

# ---------- formatted output ----------
header="${category}"
[[ -n "$subcategory" ]] && header="${header}/${subcategory}"
news_count="$(jq -r '.news.count // 0' <<<"$resp")"
tweet_count="$(jq -r '.tweets.count // 0' <<<"$resp")"

printf '\n\033[1m== Hot News: %s ==\033[0m  (%s news, %s tweets)\n\n' \
  "$header" "$news_count" "$tweet_count"

# Choose summary field based on DAILY_NEWS_LANG.
summary_field="summary_en"
[[ "$LANG_PREF" == "zh" ]] && summary_field="summary_zh"

jq -r --argjson limit "$limit" \
   --arg sf "$summary_field" \
   --arg lang "$LANG_PREF" '
  .news.items
  | sort_by(-.score)
  | .[:$limit]
  | to_entries[]
  | (.key + 1) as $n
  | .value as $it
  | "\($n | tostring | ltrimstr(" ") | if length < 2 then " "+. else . end). [\($it.score | tostring)|\($it.grade // "?"  )|\($it.signal // "?")] \($it.title)"
    + "\n    Source: \($it.source // "?")"
    + (if (($it.coins // []) | length) > 0 then "  Coins: \($it.coins | join(", "))" else "" end)
    + "\n    Link:   \($it.link)"
    + (if ($it[$sf] // "" | length) > 0 then "\n    Tldr:   \($it[$sf])" else "" end)
    + "\n"
' <<<"$resp"

# ---------- tweets (optional) ----------
if [[ "$SHOW_TWEETS" -eq 1 ]]; then
  tweet_items="$(jq '.tweets.count // 0' <<<"$resp")"
  if [[ "$tweet_items" -gt 0 ]]; then
    printf '\033[1m-- Trending Tweets --\033[0m\n\n'
    jq -r --argjson limit "$limit" '
      .tweets.items[:$limit][]
      | "@\(.handle) (\(.author))  [\(.relevance)]"
        + "\n  \(.content)"
        + "\n  \(.url)"
        + "\n  likes:\(.metrics.likes // 0)  RT:\(.metrics.retweets // 0)  replies:\(.metrics.replies // 0)"
        + "\n"
    ' <<<"$resp"
  else
    info "No tweets available for this category."
  fi
fi
