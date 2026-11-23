# bravefilter

Brave 用の個人カスタムフィルタリスト（Adblock Plus / uBlock 形式）。

## 構成

| パス | 内容 |
|---|---|
| `src/*.txt` | メインリストの元ファイル。名前順に結合される。ここを編集する |
| `src/<名前>/*.txt` | 別リストの元ファイル（例: `src/yahoo/`）。`00-header.txt` 必須 |
| `dist/filters.txt` | メインリストの生成物（手で編集しない） |
| `dist/<名前>.txt` | 別リストの生成物（例: `dist/yahoo.txt`） |
| `scripts/build.sh` | `src` → `dist` を生成 |
| `.githooks/pre-commit` | `src` を変更してコミットすると自動で build してステージ |
| `.github/workflows/check.yml` | `dist` が `src` と一致しているか CI で確認 |

## Brave への登録

1. `brave://settings/shields/filters` を開く
2. 「カスタムフィルタリスト」→「フィルタリストを URL で追加」に以下を入力
   ```
   https://raw.githubusercontent.com/tikari77/bravefilter/main/dist/filters.txt
   https://raw.githubusercontent.com/tikari77/bravefilter/main/dist/yahoo.txt
   ```
   リストごとに別々に登録する（使いたいものだけ）。
3. 以後は push すれば Brave がバックグラウンドで取り直す（基本は週1回。`Expires: 1 day` を見て早まる可能性あり）。

### すぐ反映させたいとき
- PC / Android とも `brave://adblock` を開き、カスタムリストの **オフ→オン** で再取得される
  （画面上部の「リストを更新」はカスタムリストには効かない）
- それでもダメなら削除して同じ URL で追加し直す
- push 直後は GitHub 側のキャッシュで最大5分ほど古い内容が返ることがある

※ raw URL を Brave から読むためリポジトリは **public** にする。

## 別リストを増やす

`src/<名前>/00-header.txt`（Title などを書く）とルールファイルを作れば、build で `dist/<名前>.txt` ができる。

## ルールを追加する

```sh
$EDITOR src/10-general.txt     # 例: ||ads.example.com^
git commit -am "block ads.example.com"   # pre-commit が dist を更新
git push
```

書式の例:

```
||example.com^                 ドメインごとブロック
||example.com/path/*           パスでブロック
example.com##.ad-banner        要素を非表示
example.com##+js(...)          scriptlet（Brave は一部対応）
@@||example.com/needed.js      例外
```
