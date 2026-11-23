#!/bin/bash
# ng-*.list からフィルタルールを生成して標準出力に出す
#   ng-domains.list  : リンク先ドメインで判定（Yahoo! JAPAN トップのみ。trilltrill.jp など外部記事）
#   ng-sources.list  : 記事カードの文字（見出し＋媒体名）に含まれる語で判定
#   ng-keywords.list : 同上（用途で分けているだけで動作は同じ）
# 対象ページ:
#   www.yahoo.co.jp / m.yahoo.co.jp … 記事カード = 「a を直接の子に持つ article」
#   news.yahoo.co.jp                … 記事カード = 記事リンクを含む li
set -euo pipefail
cd "$(dirname "$0")"
TOP='www.yahoo.co.jp,m.yahoo.co.jp'
words() { { grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$1" || true; } | sed -e 's/\r$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }
bad() { case $1 in *'('*|*')'*|*'"'*) echo "⚠️ yahoo: 使えない文字（括弧/引用符）を含むのでスキップ: $1" >&2; return 0;; esac; return 1; }

echo "! ===== ng-domains.list ====="
words ng-domains.list | while IFS= read -r d; do
  bad "$d" && continue
  echo "$TOP##article > a[href*=\"$d\"]:upward(1)"
done
for list in ng-sources.list ng-keywords.list; do
  echo "! ===== $list ====="
  words "$list" | while IFS= read -r w; do
    bad "$w" && continue
    echo "$TOP##article > a[href]:has-text($w):upward(1)"
    echo "news.yahoo.co.jp##a[href*=\"/articles/\"]:upward(li):has-text($w)"
    echo "news.yahoo.co.jp##a[href*=\"/pickup/\"]:upward(li):has-text($w)"
  done
done
