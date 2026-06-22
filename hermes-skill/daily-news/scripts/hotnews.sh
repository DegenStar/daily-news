#!/usr/bin/env bash
#
# hotnews.sh — fetch and pretty-print hot news from the 6551 API.
#
# Sorts news items by score (desc) and prints a compact, readable digest.
# Zero install footprint beyond curl + jq.
#
# Usage:
#   ./hotnews.sh <category> [subcategory] [limit]
#   ./hotnews.sh                       # no args -> list available categories
#
# Examples:
#   ./hotnews.sh web3                  # top news for the whole web3 category
#   ./hotnews.sh web3 defi 5           # top 5 DeFi items
#   ./hotnews.sh macro fed             # macro/fed items (default limit 10)
#
set -euo pipefail

BASE_URL="${DAILY_NEWS_API_BASE:-https://ai.6551.io}"

err() { printf 'error: %s\n' "$1" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || err "curl is required"
command -v jq   >/dev/null 2>&1 || err "jq is required"

# No category -> list what's available and exit.
if [[ $# -lt 1 ]]; then
  printf 'Available categories (pass a key as the first argument):\n\n'
  curl -fsS --max-time 20 "${BASE_URL}/open/free_categories" \
    | jq -r '.categories[]
        | "\(.key)  —  \(.name)\n  subcategories: \([.subcategories[].key] | join(", "))"'
  exit 0
fi

category="$1"
subcategory="${2:-}"
limit="${3:-10}"

[[ "$limit" =~ ^[0-9]+$ ]] || err "limit must be a positive integer (got: $limit)"

# Build the query string safely.
url="${BASE_URL}/open/free_hot?category=${category}"
[[ -n "$subcategory" ]] && url="${url}&subcategory=${subcategory}"

# Fetch; surface HTTP failures (e.g. 503 = data still generating).
resp="$(curl -fsS --max-time 30 "$url")" \
  || err "request failed (the category may still be generating data — retry shortly)"

header="$category"
[[ -n "$subcategory" ]] && header="${header}/${subcategory}"

news_count="$(jq -r '.news.count // 0' <<<"$resp")"
tweet_count="$(jq -r '.tweets.count // 0' <<<"$resp")"

printf '== Hot News: %s ==  (%s news, %s tweets)\n\n' "$header" "$news_count" "$tweet_count"

jq -r --argjson limit "$limit" '
  .news.items
  | sort_by(-.score)
  | .[:$limit][]
  | "[\(.score)|\(.grade // "?")|\(.signal // "neutral")] \(.title)\n"
    + "    \(.source // "?")  \(if (.coins|length) > 0 then "(\(.coins|join(", ")))" else "" end)\n"
    + "    \(.link)\n"
' <<<"$resp"
