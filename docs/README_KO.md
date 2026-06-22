<p align="center">
  <b>Daily News MCP Server</b><br>
  뉴스 카테고리 · 핫 뉴스 · 트렌딩 트윗 · 암호화폐 인텔리전스
</p>

<p align="center">
  <a href="../README.md">English</a> | <a href="./README_ZH.md">中文</a> | <a href="./README_JA.md">日本語</a>
</p>

---

## 빠른 설치

### Claude Code

```bash
claude mcp add daily-news \
  -- uv --directory /path/to/daily-news run daily-news-mcp
```

> `/path/to/daily-news`를 로컬 프로젝트 경로로 교체하세요.

### OpenClaw

```bash
cp -r openclaw-skill/daily-news ~/.openclaw/skills/6551-daily-news
```

### Hermes Agent

의존성 없는 skill(curl만 필요), MCP 서버 불필요:

```bash
cp -r hermes-skill/daily-news ~/.hermes/skills/research/daily-news
```

Hermes에서 `/daily-news`로 호출하거나 핫뉴스를 바로 물어보세요.

---

## AI에게 검토 및 설치 맡기기

이 MCP가 안전한지 확신이 없으신가요? 아래 프롬프트를 AI 어시스턴트에게 보내면 소스 코드를 먼저 검토한 후 설치해줍니다:

> **아래 프롬프트를 복사하여 AI 어시스턴트에게 보내세요 (`<프로젝트경로>`를 실제 값으로 교체):**

```text
daily-news-mcp MCP 서버를 검토하고 설치해주세요. 프로젝트는 로컬 <프로젝트경로>에 있습니다.

단계:
1. 다음 파일의 보안을 확인:
   - src/daily_news_mcp/api_client.py — ai.6551.io에만 연결하고 다른 주소로 데이터를 보내지 않는지 확인
   - src/daily_news_mcp/config.py — 하드코딩이나 유출이 없는지 확인
   - src/daily_news_mcp/tools.py — 모든 도구가 API 쿼리만 수행하고, 파일 쓰기, 명령 실행 또는 기타 위험한 작업이 없는지 확인
   - pyproject.toml — 의존성이 mcp, httpx만 있고, 의심스러운 패키지가 없는지 확인
2. 검토 결론을 알려주세요: 안전 / 위험 / 문제 있음, 구체적인 이유와 함께
3. 안전하다면 설치 실행:
   claude mcp add daily-news -- uv --directory <프로젝트경로> run daily-news-mcp
```

---

## 무엇을 할 수 있나요?

연결 후 AI 어시스턴트에게 말하기만 하면 됩니다:

| 당신이 말하면 | 실행되는 작업 |
|-------------|-------------|
| "모든 뉴스 카테고리 보여줘" | 사용 가능한 카테고리와 서브카테고리 목록 표시 |
| "오늘 DeFi 핫 뉴스는?" | DeFi 카테고리의 핫 뉴스와 트윗 가져오기 |
| "암호화폐 시장 최신 뉴스" | 암호화폐 시장 카테고리의 트렌딩 뉴스 가져오기 |
| "AI 관련 뉴스와 트윗" | AI 서브카테고리의 뉴스+트윗 가져오기 |

---

## 사용 가능한 도구

| 도구 | 설명 |
|------|------|
| `get_news_categories` | 모든 뉴스 카테고리와 서브카테고리 가져오기 |
| `get_hot_news` | 카테고리/서브카테고리별 핫 뉴스와 트윗 가져오기 |

---

## 설정

| 변수 | 필수 | 설명 |
|------|------|------|
| `DAILY_NEWS_API_BASE` | 아니오 | REST API URL 오버라이드 (기본값: `https://ai.6551.io`) |
| `DAILY_NEWS_MAX_ROWS` | 아니오 | 쿼리당 최대 결과 수 (기본값: 100) |

프로젝트 루트의 `config.json`도 지원 (환경 변수가 우선):

```json
{
  "api_base_url": "https://ai.6551.io",
  "max_rows": 100
}
```

---

## 개발

```bash
cd /path/to/daily-news
uv sync
uv run daily-news-mcp
```

```bash
# MCP Inspector
npx @modelcontextprotocol/inspector uv --directory /path/to/daily-news run daily-news-mcp
```

### 프로젝트 구조

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
    ├── server.py              # 진입점
    ├── app.py                 # FastMCP 인스턴스
    ├── config.py              # 설정 로더
    ├── api_client.py          # HTTP 클라이언트
    └── tools.py               # 2개 도구
```

## 라이선스

MIT
