# Issue Tracking

このディレクトリは、開発中に発見した問題や改修が必要な箇所を記録するためのものです。

## ファイル命名規則

```
{番号}_{概要}.md
```

例: `001_remove_debug_skip_buttons.md`

## ステータス管理

各issueファイル内でチェックボックスを使用：
- `[ ]` 未対応
- `[x]` 対応済み

## Issue一覧

| # | ファイル | 概要 | ステータス | 優先度 |
|---|----------|------|-----------|--------|
| 001 | [001_remove_debug_skip_buttons.md](./001_remove_debug_skip_buttons.md) | デバッグ用スキップボタンの削除 | 未対応 | 高 |

---

## 検索コマンド

```bash
# 全TODOコメントを検索
grep -rn "TODO" lib/

# デバッグ用コードを検索
grep -rn "TODO: デバッグ用" lib/

# FIXMEを検索
grep -rn "FIXME" lib/
```
