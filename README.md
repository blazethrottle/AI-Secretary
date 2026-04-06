# AI-Secretary

**LLM이 점진적으로 구축하고 유지하는 개인 지식 체계**

---

## 소개

AI-Secretary는 Andrej Karpathy의 [LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을 기반으로 한 AI 지식 베이스입니다.

기존 RAG 방식과 달리, LLM이 **구조화된 마크다운 위키를 점진적으로 구축**합니다. 소스가 추가될 때마다 위키가 풍부해지고, 교차 참조가 생기며, 지식이 복리적으로 축적됩니다.

## 구조

```
sources/
  obsidian-vault/         ← [심볼릭 링크 → Obsidian Vault]   주 소스
  articles/, papers/, ... ← Vault 외부 보조 소스
wiki/                     ← 지식 위키 (LLM이 생성·유지)
CLAUDE.md                 ← 스키마·워크플로우 정의
scripts/setup-obsidian-source.sh  ← 양방향 심볼릭 링크 생성
```

추가로, 셋업 시 Vault 안에 다음 링크가 만들어집니다:

```
<Obsidian Vault>/
  ai-wiki/   ← [심볼릭 링크 → 이 레포의 wiki/]
```

→ Obsidian을 열면 사용자 노트와 LLM이 생성한 위키가 **한 Vault 안에서**
   그래프 뷰·백링크·전역 검색으로 묶여 보입니다.

## 핵심 운영

| 운영 | 설명 |
|------|------|
| **Ingest** | 새 소스 추가 → LLM이 요약, 엔티티, 개념 페이지 생성·업데이트 |
| **Query** | 위키에 질문 → LLM이 종합 답변 생성, 가치 있으면 페이지로 저장 |
| **Lint** | 위키 점검 → 모순, 고아 페이지, 누락 참조 탐지 |

## 역할 분담

- **사용자**: 소스 큐레이션, 분석 방향, 질문, 의미 해석
- **LLM**: 요약, 교차 참조, 파일 정리, 인덱스 유지, 종합 분석

## 시작하기

1. **Obsidian Vault 연결** (한 번만, 양방향 심볼릭 링크):
   ```bash
   ./scripts/setup-obsidian-source.sh
   # 또는 커스텀 경로
   ./scripts/setup-obsidian-source.sh "/path/to/your/Obsidian Vault"
   ```
   기본 경로는 `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault` 입니다.
   스크립트는 다음 두 링크를 만듭니다 (둘 다 `.gitignore` 처리):
   - `sources/obsidian-vault` → Vault (LLM이 raw source로 읽기)
   - `<Vault>/ai-wiki` → 이 레포의 `wiki/` (Obsidian에서 LLM 산출물 보기)
2. Vault에 노트를 추가하거나 보조 소스를 `sources/<카테고리>/`에 넣습니다
3. LLM에게 수집(ingest)을 요청합니다
4. 위키에 대해 질문(query)합니다
5. 주기적으로 점검(lint)을 실행합니다

> LLM은 Vault를 **읽기 전용**으로만 사용합니다. 모든 분석 결과는 `wiki/` 하위에 별도 페이지로 저장됩니다.

자세한 워크플로우는 [CLAUDE.md](CLAUDE.md)를 참조하세요.
