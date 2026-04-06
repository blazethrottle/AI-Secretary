# AI-Secretary: AI 지식 체계 (LLM Wiki)

> LLM이 점진적으로 구축하고 유지하는 영속적 개인 지식 베이스

---

## 프로젝트 개요

이 프로젝트는 **LLM Wiki 패턴**을 기반으로 한 AI 지식 체계입니다.
RAG(검색-증강-생성)처럼 매번 원시 문서에서 지식을 재발견하는 대신,
LLM이 **구조화된 마크다운 위키를 점진적으로 구축·유지**합니다.

위키는 소스가 추가될 때마다 풍부해지는 **복리적(compounding) 지식 자산**입니다.

---

## 아키텍처 (3계층)

```
AI-Secretary/
├── CLAUDE.md          ← 스키마 계층: 구조, 컨벤션, 워크플로우 정의
├── README.md          ← 프로젝트 소개
├── scripts/
│   └── setup-obsidian-source.sh  ← Obsidian Vault → sources/obsidian-vault 심볼릭 링크
├── sources/           ← 원시 소스 계층: 불변의 원본 자료
│   ├── obsidian-vault/  ← (심볼릭 링크 → Vault, gitignore) **주 소스: 사용자의 Obsidian Vault**
│   ├── articles/      ← (보조) Vault 외부 아티클·블로그 포스트
│   ├── papers/        ← (보조) Vault 외부 논문·리서치 페이퍼
│   ├── books/         ← (보조) Vault 외부 책 노트
│   ├── podcasts/      ← (보조) Vault 외부 팟캐스트 트랜스크립트
│   ├── videos/        ← (보조) Vault 외부 영상 노트
│   ├── journals/      ← (보조) Vault 외부 저널
│   ├── conversations/ ← (보조) Vault 외부 대화·미팅 노트
│   ├── data/          ← (보조) 데이터, 이미지, 기타 파일
│   └── misc/          ← (보조) 기타 분류되지 않는 자료
├── wiki/              ← 위키 계층: LLM이 생성·유지하는 지식 페이지
│                        (Vault 안의 ai-wiki/ 가 이곳을 가리키는 심볼릭 링크)
│   ├── index.md       ← 전체 페이지 카탈로그
│   ├── log.md         ← 작업 로그 (시간순 기록)
│   ├── entities/      ← 엔티티 페이지 (인물, 조직, 제품 등)
│   ├── concepts/      ← 개념 페이지 (이론, 프레임워크, 아이디어)
│   ├── summaries/     ← 소스 요약 페이지
│   ├── syntheses/     ← 종합·비교·분석 페이지
│   ├── questions/     ← 질문-답변 페이지 (탐구 결과물)
│   └── maps/          ← 주제 맵, 개요, 로드맵
└── .gitignore
```

### 계층 설명

| 계층 | 역할 | 소유자 |
|------|------|--------|
| **원시 소스 (sources/)** | 불변의 원본 자료. 진실의 원천(source of truth). | 사용자 |
| **위키 (wiki/)** | LLM이 생성한 구조화된 지식 페이지. 요약, 엔티티, 개념, 종합, 비교. | LLM |
| **스키마 (CLAUDE.md)** | 위키 구조, 컨벤션, 워크플로우 정의. 사용과 함께 진화. | 사용자 + LLM |

---

## Obsidian Vault 통합 (양방향 심볼릭 링크)

이 프로젝트는 사용자의 기존 Obsidian Vault를 **소스이자 위키 뷰어**로 통합합니다.
karpathy LLM Wiki 패턴의 "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase" 비유를 그대로 구현합니다.

### 두 개의 심볼릭 링크

```
[1] sources/obsidian-vault       →  <Vault>           (LLM이 raw source로 읽음)
[2] <Vault>/ai-wiki              →  <repo>/wiki       (Obsidian이 LLM 산출물을 표시)
```

- **[1]** 덕분에 LLM은 레포 안에서 Vault 노트 전체를 raw source로 읽을 수 있습니다.
- **[2]** 덕분에 사용자는 Obsidian을 열면 자기 노트와 함께 `ai-wiki/` 폴더 안에 LLM이 생성한 위키 페이지가 보이고, **그래프 뷰·백링크·검색이 모두 한 Vault 안에서 작동**합니다.
- 두 링크 모두 `.gitignore` 처리되어 머신별로 다른 경로를 가질 수 있습니다.

### 셋업 (각 머신에서 1회)

```bash
./scripts/setup-obsidian-source.sh
# 또는 커스텀 경로
./scripts/setup-obsidian-source.sh "/path/to/Obsidian Vault"
```

기본 Vault 경로:
```
/Users/taehoonkim-mini/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault
```

스크립트는 멱등(idempotent)이며 안전하게 여러 번 재실행할 수 있습니다.

### LLM 동작 규칙

1. **Vault는 읽기 전용**: `sources/obsidian-vault/` 하위의 어떤 파일도 **수정·생성·삭제하지 않습니다**. Vault는 사용자의 진실 원천입니다.
2. **위키는 자유롭게 쓰기**: `wiki/` 하위는 LLM이 소유. 모든 ingest/query 산출물은 여기에만 작성합니다. (이 폴더는 Vault 안의 `ai-wiki/`에서 그대로 보입니다.)
3. **인용 경로 규칙**:
   - Vault 노트 인용: `sources/obsidian-vault/<vault 내 상대경로>`
   - 위키 내부 링크: 상대 마크다운 링크 `[text](../concepts/x.md)` (Obsidian 위키링크 `[[...]]` 대신)
4. **Vault 노이즈 무시**: 다음은 인덱싱/요약 대상에서 제외합니다:
   - `.obsidian/`, `.trash/`, `.smart-env/`, `ai-wiki/` (자기 자신!) 등
   - `*.canvas`, `*.excalidraw` 비텍스트 노트는 메타데이터만 기록
   - 첨부 폴더의 이미지·바이너리는 필요할 때만 별도 호출로 확인
5. **위키링크 해석**: Vault 노트의 `[[Page Name]]`은 가능한 한 해당 노트로 해석. 단 위키 페이지를 새로 작성할 때는 항상 마크다운 상대링크를 사용합니다 (Obsidian/일반 마크다운 둘 다 호환).
6. **태그 정규화**: Obsidian `#tag` / YAML `tags:` 를 위키 frontmatter의 `tags`로 옮길 때 소문자·하이픈 구분으로 정규화합니다.
7. **양방향 동기화 금지**: Vault → 위키 한 방향. 위키 인사이트를 Vault에 반영하고 싶으면 사용자가 수동으로 옮깁니다.
8. **자기 참조 루프 주의**: `sources/obsidian-vault/ai-wiki/` 경로는 사실 `wiki/` 자신을 가리킵니다. 절대 raw source로 취급하지 않습니다.

### Vault 탐색 워크플로우 (Ingest)

새 ingest 요청 시 LLM은 다음 순서로 진행합니다:

1. `sources/obsidian-vault/` 상위 구조 파악 (Glob)
2. 사용자가 지정한 노트 또는 최근 수정 노트 확인
3. 노트 본문·프론트매터·위키링크 분석
4. **사용자와 핵심 takeaway 짧게 논의**
5. `wiki/summaries/`에 요약 페이지 생성 (소스 경로 인용)
6. 엔티티/개념 페이지 생성·업데이트
7. `wiki/index.md`, `wiki/log.md` 갱신
8. (선택) 사용자가 Obsidian으로 결과를 확인하도록 유도

---

## 핵심 운영 (Operations)

### 1. Ingest (수집)

새로운 소스를 `sources/`에 추가하면 LLM이 다음을 수행합니다:

1. 소스를 읽고 핵심 내용을 파악
2. **사용자와 핵심 takeaway를 짧게 논의** (강조점, 무시할 부분, 분류 방향 확인)
3. `wiki/summaries/`에 소스 요약 페이지 생성
4. 관련 엔티티 페이지 생성 또는 업데이트 (`wiki/entities/`)
5. 관련 개념 페이지 생성 또는 업데이트 (`wiki/concepts/`)
6. 기존 페이지와의 교차 참조(cross-reference) 추가
7. 모순점(contradictions) 발견 시 플래그
8. `wiki/index.md` 업데이트
9. `wiki/log.md`에 수집 기록 추가

**하나의 소스가 10~15개 페이지에 영향을 줄 수 있습니다.**
**기본은 1건씩 사용자와 함께 처리하는 흐름이며, 배치 ingest는 명시적 요청 시에만.**

### 2. Query (질의)

위키에 대해 질문하면 LLM이 다음을 수행합니다:

1. **먼저 `wiki/index.md`를 읽어** 후보 페이지를 식별 (embedding RAG 회피의 핵심 트릭)
2. 후보 페이지를 드릴다운하여 본문 확인
3. 필요 시 `sources/`의 원본까지 거슬러 올라가 검증
4. 소스 인용과 함께 종합적 답변 생성
5. 답변이 가치 있으면 `wiki/questions/` 또는 `wiki/syntheses/`에 새 페이지로 저장
6. `wiki/log.md`에 질의 기록 추가

**좋은 답변은 위키 페이지로 저장되어 지식이 복리적으로 축적됩니다.**

### 3. Lint (점검)

주기적으로 위키 건강 상태를 점검합니다:

- 모순된 주장 탐지
- 오래된(stale) 정보 식별
- 고아 페이지(orphan pages) 발견
- 누락된 개념 페이지 제안
- 빠진 교차 참조 보완
- 데이터 갭 식별 및 새 소스 제안
- **새로 조사할 질문(open questions) 제안** — 위키가 다음 ingest를 능동적으로 견인

---

## 페이지 컨벤션

### 프론트매터 (Frontmatter)

모든 위키 페이지는 YAML 프론트매터를 포함합니다:

```yaml
---
title: "페이지 제목"
type: summary | entity | concept | synthesis | question | map
created: 2026-04-06
updated: 2026-04-06
sources:
  - sources/obsidian-vault/path/to/note.md
  - sources/articles/example.md
tags:
  - tag1
  - tag2
related:
  - wiki/concepts/related-concept.md
  - wiki/entities/related-entity.md
---
```

### 교차 참조

위키 내부 링크는 상대 경로를 사용합니다:

```markdown
자세한 내용은 [개념명](../concepts/concept-name.md)을 참조하세요.
관련 인물: [인물명](../entities/person-name.md)
```

### 파일 명명 규칙

- 소문자 + 하이픈 구분: `concept-name.md`
- 영어 또는 한글 사용 가능 (일관성 유지)
- 날짜 포함 시: `2026-04-06-topic.md`

---

## 인덱스 관리 (index.md)

`wiki/index.md`는 전체 위키의 카탈로그입니다:

- 모든 페이지를 카테고리별로 정리
- 각 페이지의 링크, 요약, 메타데이터(날짜, 소스 수) 포함
- 모든 수집(ingest) 작업 시 업데이트

---

## 로그 관리 (log.md)

`wiki/log.md`는 시간순 추가 전용(append-only) 기록입니다:

```markdown
## [2026-04-06] ingest | 소스 제목
- 요약 페이지 생성: wiki/summaries/source-title.md
- 엔티티 업데이트: wiki/entities/entity-name.md
- 새 개념 페이지: wiki/concepts/new-concept.md

## [2026-04-06] query | 질문 내용
- 답변 페이지 생성: wiki/questions/question-topic.md
- 관련 페이지 참조: wiki/concepts/...

## [2026-04-06] lint | 위키 점검
- 발견된 이슈: ...
- 제안 사항: ...
```

일관된 접두사 형식으로 유닉스 도구로 파싱 가능합니다. 예:

```bash
grep "^## \[" wiki/log.md | tail -5      # 최근 5건
grep "^## \[.*\] ingest" wiki/log.md     # ingest 만
grep "^## \[2026-04" wiki/log.md         # 2026년 4월 활동
```

---

## 역할 분담

| 역할 | 사용자 | LLM |
|------|--------|-----|
| 소스 큐레이션 | O | |
| 분석 방향 설정 | O | |
| 질문 제기 | O | |
| 의미 해석 | O | |
| 요약 작성 | | O |
| 교차 참조 관리 | | O |
| 파일 정리·분류 | | O |
| 인덱스·로그 유지 | | O |
| 모순점 탐지 | | O |
| 종합·비교 분석 | | O |

---

## 출력 형식

위키 페이지 외에도 다양한 형식으로 출력할 수 있습니다:

- **마크다운 페이지** — 기본 출력
- **비교 테이블** — 개념·엔티티 비교
- **슬라이드 덱** — Marp 기반 프레젠테이션
- **차트·시각화** — matplotlib 등 활용
- **캔버스** — 관계도, 마인드맵

---

## 팁

- **Obsidian Web Clipper**: 웹 아티클을 마크다운으로 빠르게 변환 → Vault에 저장
- **이미지 로컬 다운로드**: URL 의존 대신 로컬 저장. Obsidian Settings → Files and links → "Attachment folder path"를 고정 폴더(예: `assets/`)로 지정 후, "Download attachments for current file" 핫키 바인딩
- **이미지는 2단계로 읽기**: LLM은 마크다운+인라인 이미지를 한 번에 처리하지 못함. 본문 텍스트 먼저 → 필요한 이미지만 별도 호출로 확인
- **Obsidian 그래프 뷰**: 위키 연결성 시각화 (허브와 고아 페이지 식별)
- **Git 히스토리**: 버전 관리, 브랜칭, 협업 지원
- **Dataview 플러그인**: 프론트매터 기반 동적 테이블 생성
- **위키가 커지면 검색 엔진 도입**: index.md 만으로 부족해지면 [qmd](https://github.com/tobi/qmd) 같은 로컬 BM25/벡터 하이브리드 검색을 CLI/MCP로 추가
- **다른 에이전트 호환**: Codex/OpenCode 등을 함께 쓰려면 `AGENTS.md`를 만들어 같은 내용을 심볼릭 링크 또는 복사로 공유

---

## 세션 컨텍스트 관리

### 자동 저장 (PostCompact Hook)

`/compact` 또는 auto-compact 실행 시, compaction summary가 자동으로 `.claude/session-context.md`에 저장됩니다.

### 수동 저장 (/clear 전 필수)

**`/clear` 요청을 받으면 LLM은 반드시 다음을 실행한 후 clear해야 합니다:**

1. 현재 세션의 핵심 맥락을 `.claude/session-context.md`에 저장:
   - 이번 세션에서 수행한 작업 요약
   - 진행 중이던 미완료 작업
   - 다음 세션에서 이어야 할 사항
   - 주요 결정 사항 및 그 이유
2. 파일 형식:

```markdown
---
saved_at: "YYYY-MM-DD HH:MM:SS"
type: manual-session-summary
---

# Session Context

## 완료된 작업
- ...

## 진행 중 / 미완료
- ...

## 다음 세션 TODO
- ...

## 주요 결정 사항
- ...
```

### 세션 시작 시

새 세션이 시작되면 LLM은 `.claude/session-context.md` 파일이 존재하는지 확인하고, 존재하면 읽어서 이전 맥락을 파악한 후 작업을 이어갑니다.

---

## 설계 철학

> "지식 베이스 유지의 지루한 부분은 읽기나 사고가 아니라 **관리(bookkeeping)**다."

인간은 유지 부담이 가치를 초과하면 위키를 포기합니다.
LLM은 지루해하지 않고, 교차 참조를 잊지 않으며, 다중 파일 업데이트에 어려움을 겪지 않습니다.

**인간의 역할**: 소스 큐레이션, 분석 방향 설정, 좋은 질문, 의미 사고
**LLM의 역할**: 그 외 모든 것
