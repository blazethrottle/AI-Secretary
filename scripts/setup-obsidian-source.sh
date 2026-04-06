#!/usr/bin/env bash
#
# setup-obsidian-source.sh
#
# Obsidian Vault를 sources/obsidian-vault 심볼릭 링크로 연결합니다.
# 이 링크는 git에 커밋되지 않으며 (.gitignore 처리), 각 머신에서 1회 실행합니다.
#
# 사용법:
#   ./scripts/setup-obsidian-source.sh
#   ./scripts/setup-obsidian-source.sh "/custom/path/to/Obsidian Vault"

set -euo pipefail

DEFAULT_VAULT="/Users/taehoonkim-mini/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
VAULT_PATH="${1:-$DEFAULT_VAULT}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LINK_PATH="$REPO_ROOT/sources/obsidian-vault"

if [ ! -d "$VAULT_PATH" ]; then
  echo "ERROR: Obsidian Vault를 찾을 수 없습니다:" >&2
  echo "  $VAULT_PATH" >&2
  echo "" >&2
  echo "사용법: $0 [vault-path]" >&2
  exit 1
fi

if [ -L "$LINK_PATH" ]; then
  echo "기존 심볼릭 링크 제거: $LINK_PATH"
  rm "$LINK_PATH"
elif [ -e "$LINK_PATH" ]; then
  echo "ERROR: $LINK_PATH 가 이미 존재하지만 심볼릭 링크가 아닙니다." >&2
  echo "수동으로 확인 후 제거하세요." >&2
  exit 1
fi

ln -s "$VAULT_PATH" "$LINK_PATH"
echo "✓ 심볼릭 링크 생성됨:"
echo "  $LINK_PATH"
echo "  → $VAULT_PATH"
echo ""
echo "확인:"
ls -la "$LINK_PATH"
