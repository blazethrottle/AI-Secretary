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
├── sources/           ← 원시 소스 계층: 불변의 원본 자료
│   ├── articles/      ← 아티클, 블로그 포스트
│   ├── papers/        ← 논문, 리서치 페이퍼
│   ├── books/         ← 책 요약, 챕터 노트
│   ├── podcasts/      ← 팟캐스트 노트, 트랜스크립트
│   ├── videos/        ← 영상 노트, 트랜스크립트
│   ├── journals/      ← 개인 저널, 일기
│   ├── conversations/ ← 대화 기록, 미팅 노트
│   ├── data/          ← 데이터, 이미지, 기타 파일
│   └── misc/          ← 기타 분류되지 않는 자료
├── wiki/              ← 위키 계층: LLM이 생성·유지하는 지식 페이지
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

## 핵심 운영 (Operations)

### 1. Ingest (수집)

새로운 소스를 `sources/`에 추가하면 LLM이 다음을 수행합니다:

1. 소스를 읽고 핵심 내용을 파악
2. `wiki/summaries/`에 소스 요약 페이지 생성
3. 관련 엔티티 페이지 생성 또는 업데이트 (`wiki/entities/`)
4. 관련 개념 페이지 생성 또는 업데이트 (`wiki/concepts/`)
5. 기존 페이지와의 교차 참조(cross-reference) 추가
6. 모순점(contradictions) 발견 시 플래그
7. `wiki/index.md` 업데이트
8. `wiki/log.md`에 수집 기록 추가

**하나의 소스가 10~15개 페이지에 영향을 줄 수 있습니다.**

### 2. Query (질의)

위키에 대해 질문하면 LLM이 다음을 수행합니다:

1. 관련 위키 페이지를 검색·탐색
2. 소스 인용과 함께 종합적 답변 생성
3. 답변이 가치 있으면 `wiki/questions/` 또는 `wiki/syntheses/`에 새 페이지로 저장
4. `wiki/log.md`에 질의 기록 추가

**좋은 답변은 위키 페이지로 저장되어 지식이 복리적으로 축적됩니다.**

### 3. Lint (점검)

주기적으로 위키 건강 상태를 점검합니다:

- 모순된 주장 탐지
- 오래된(stale) 정보 식별
- 고아 페이지(orphan pages) 발견
- 누락된 개념 페이지 제안
- 빠진 교차 참조 보완
- 데이터 갭 식별 및 새 소스 제안

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

일관된 접두사 형식으로 유닉스 도구로 파싱 가능합니다.

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

- **Obsidian Web Clipper**: 웹 아티클을 마크다운으로 빠르게 변환
- **이미지 로컬 다운로드**: URL 의존 대신 로컬 저장
- **Obsidian 그래프 뷰**: 위키 연결성 시각화 (허브와 고아 페이지 식별)
- **Git 히스토리**: 버전 관리, 브랜칭, 협업 지원
- **Dataview 플러그인**: 프론트매터 기반 동적 테이블 생성

---

## 설계 철학

> "지식 베이스 유지의 지루한 부분은 읽기나 사고가 아니라 **관리(bookkeeping)**다."

인간은 유지 부담이 가치를 초과하면 위키를 포기합니다.
LLM은 지루해하지 않고, 교차 참조를 잊지 않으며, 다중 파일 업데이트에 어려움을 겪지 않습니다.

**인간의 역할**: 소스 큐레이션, 분석 방향 설정, 좋은 질문, 의미 사고
**LLM의 역할**: 그 외 모든 것
