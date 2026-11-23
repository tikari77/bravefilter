#!/bin/bash
# src/*.txt を名前順に結合して dist/filters.txt を作る
set -euo pipefail
cd "$(dirname "$0")/.."
out=dist/filters.txt
tmp=$(mktemp)
{
  cat src/00-header.txt
  echo "! Version: $(git log -1 --format=%cd --date=format:%Y%m%d%H%M 2>/dev/null || date +%Y%m%d%H%M)"
  for f in src/*.txt; do
    [ "$f" = src/00-header.txt ] && continue
    echo
    echo "! --- $(basename "$f") ---"
    # 行末空白と CR を除去
    sed -e 's/\r$//' -e 's/[[:space:]]*$//' "$f"
  done
} > "$tmp"
# 重複ルール警告（コメント・空行除く）
dups=$(grep -v -e '^!' -e '^$' "$tmp" | LC_ALL=C sort | LC_ALL=C uniq -d || true)
[ -n "$dups" ] && { echo "⚠️ 重複ルール:"; echo "$dups"; } >&2
mv "$tmp" "$out"
echo "built $out ($(grep -cv -e '^!' -e '^$' "$out" || true) rules)"
