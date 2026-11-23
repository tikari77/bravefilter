#!/bin/bash
# ng-sources.list / ng-keywords.list からフィルタルールを生成して標準出力に出す
# 記事カード（媒体名・見出しを含む）にその語が含まれていればカードごと非表示
set -euo pipefail
cd "$(dirname "$0")"
emit() { # emit <word>
  local w=$1
  case $w in *'('*|*')'*) echo "⚠️ yahoo: 括弧を含む語はスキップ: $w" >&2; return;; esac
  # Yahoo! JAPAN トップ（PC: www / スマホ: m）: 1記事 = article 要素
  echo "www.yahoo.co.jp,m.yahoo.co.jp##a[href*=\"news.yahoo.co.jp/\"]:upward(article):has-text($w)"
  # Yahoo!ニュース: 1記事 = li 要素（通常記事 /articles/ とトピックス /pickup/）
  echo "news.yahoo.co.jp##a[href*=\"/articles/\"]:upward(li):has-text($w)"
  echo "news.yahoo.co.jp##a[href*=\"/pickup/\"]:upward(li):has-text($w)"
}
for list in ng-sources.list ng-keywords.list; do
  echo "! ===== $list ====="
  { grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$list" || true; } | sed -e 's/\r$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' |
    while IFS= read -r w; do echo "! $w"; emit "$w"; done
done
