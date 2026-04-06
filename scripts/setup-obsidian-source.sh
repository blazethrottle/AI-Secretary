#!/usr/bin/env bash
#
# setup-obsidian-source.sh
#
# Karpathy LLM Wiki 패턴 기반 Obsidian 통합 셋업.
# 다음 두 개의 심볼릭 링크를 생성합니다:
#
#   1) <repo>/sources/obsidian-vault       → <Vault>
#      (LLM이 Vault 노트를 raw source로 읽기 위함)
#
#   2) <Vault>/ai-wiki                     → <repo>/wiki
#      (Obsidian에서 LLM이 생성한 위키를 그래프 뷰·백링크로 탐색하기 위함)
#
# 두 링크 모두 .gitignore 처리되어 머신마다 다른 경로를 가질 수 있습니다.
# 각 머신에서 1회 실행하면 되며, 안전하게 여러 번 재실행해도 됩니다.
#
# 사용법:
#   ./scripts/setup-obsidian-source.sh
#   ./scripts/setup-obsidian-source.sh "/path/to/Obsidian Vault"

set -euo pipefail

DEFAULT_VAULT="/Users/taehoonkim-mini/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
VAULT_PATH="${1:-$DEFAULT_VAULT}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_LINK="$REPO_ROOT/sources/obsidian-vault"
WIKI_TARGET="$REPO_ROOT/wiki"
VAULT_WIKI_LINK="$VAULT_PATH/ai-wiki"

# ── 사전 점검 ──────────────────────────────────────────────
if [ ! -d "$VAULT_PATH" ]; then
  echo "ERROR: Obsidian Vault를 찾을 수 없습니다:" >&2
  echo "  $VAULT_PATH" >&2
  echo "" >&2
  echo "사용법: $0 [vault-path]" >&2
  exit 1
fi

if [ ! -d "$WIKI_TARGET" ]; then
  echo "ERROR: 레포의 wiki 디렉토리를 찾을 수 없습니다: $WIKI_TARGET" >&2
  exit 1
fi

echo "Vault:    $VAULT_PATH"
echo "Repo:     $REPO_ROOT"
echo ""

# ── 안전한 심볼릭 링크 생성 헬퍼 ────────────────────────────
make_symlink() {
  local target="$1"
  local link="$2"
  local label="$3"

  if [ -L "$link" ]; then
    local current
    current="$(readlink "$link")"
    if [ "$current" = "$target" ]; then
      echo "✓ [$label] 이미 올바르게 연결됨: $link"
      return 0
    fi
    echo "  [$label] 기존 심볼릭 링크 갱신: $link"
    echo "    이전: $current"
    rm "$link"
  elif [ -e "$link" ]; then
    echo "ERROR: [$label] $link 가 이미 존재하지만 심볼릭 링크가 아닙니다." >&2
    echo "수동으로 확인 후 백업·제거하세요." >&2
    return 1
  fi

  ln -s "$target" "$link"
  echo "✓ [$label] 생성됨: $link"
  echo "    → $target"
}

# ── (1) Vault → repo sources ───────────────────────────────
echo "[1/2] sources/obsidian-vault → Vault"
make_symlink "$VAULT_PATH" "$SRC_LINK" "source"
echo ""

# ── (2) repo wiki → Vault 안의 ai-wiki ─────────────────────
echo "[2/2] <Vault>/ai-wiki → repo wiki/"
make_symlink "$WIKI_TARGET" "$VAULT_WIKI_LINK" "wiki-view"
echo ""

# ── 결과 확인 ──────────────────────────────────────────────
echo "─── 확인 ───"
ls -la "$SRC_LINK" 2>/dev/null || true
ls -la "$VAULT_WIKI_LINK" 2>/dev/null || true
echo ""
echo "완료. Obsidian에서 Vault를 열면 사이드바에 'ai-wiki' 폴더가 나타나며,"
echo "그래프 뷰에서 LLM이 생성한 위키 페이지들이 기존 노트와 함께 표시됩니다."
