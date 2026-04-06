#!/bin/bash
# save-session-context.sh
# PostCompact hook: compaction summary를 세션 컨텍스트 파일로 저장
# 다음 세션에서 맥락을 이어받을 수 있도록 함

PROJ_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONTEXT_FILE="$PROJ_DIR/.claude/session-context.md"

mkdir -p "$PROJ_DIR/.claude"

# stdin에서 hook input JSON 읽기
INPUT=$(cat)

# compaction summary 추출 시도 (다양한 JSON 경로)
SUMMARY=$(echo "$INPUT" | jq -r '
  .summary //
  .tool_response.summary //
  .tool_response //
  .content //
  .
' 2>/dev/null)

# summary가 비어있지 않으면 저장
if [ -n "$SUMMARY" ] && [ "$SUMMARY" != "null" ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  cat > "$CONTEXT_FILE" <<EOMD
---
saved_at: "${TIMESTAMP}"
type: auto-compact-summary
---

# Session Context (auto-saved)

> Auto-saved by PostCompact hook at ${TIMESTAMP}

${SUMMARY}
EOMD
fi
