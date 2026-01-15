# Issue #001: デバッグ用スキップボタンの削除

## ステータス
- [x] 完了 (2025-12-25)

## 優先度
**高** - リリース前に必ず対応

## 概要
開発効率化のために追加したデバッグ用スキップボタンを、リリース前に削除する必要がある。

## 対象ファイル

### 1. `lib/screens/input_training_screen.dart`
- **行番号**: 369-373付近
- **内容**: ヘッダーにある「Skip」ボタン
- **マーカー**: `// TODO: デバッグ用 - リリース時に削除`

```dart
// TODO: デバッグ用 - リリース時に削除
TextButton(
  onPressed: _navigateToCheckTime,
  child: const Text('Skip', style: TextStyle(color: Colors.red)),
),
```

**修正方法**: 上記を削除し、以下に置き換える
```dart
const SizedBox(width: 48), // バランス用
```

---

### 2. `lib/screens/check_time_screen_v2.dart`

#### 2-1. スキップボタン（UI部分）
- **行番号**: 330-335付近
- **内容**: タイトル下にある「Skip to Q7」ボタン
- **マーカー**: `// TODO: デバッグ用 - リリース時に削除`

```dart
// TODO: デバッグ用 - リリース時に削除
TextButton(
  onPressed: _skipToQuestion7,
  child: const Text('Skip to Q7', style: TextStyle(color: Colors.red, fontSize: 12)),
),
```

**修正方法**: 上記5行を削除

#### 2-2. スキップメソッド
- **行番号**: 203-220付近
- **内容**: `_skipToQuestion7()` メソッド
- **マーカー**: `// TODO: デバッグ用 - リリース時に削除`

```dart
// TODO: デバッグ用 - リリース時に削除
void _skipToQuestion7() {
  // ... メソッド全体
}
```

**修正方法**: メソッド全体を削除

---

## 検索コマンド

```bash
# 対象箇所を一括検索
grep -rn "TODO: デバッグ用" lib/
```

## 作成日
2025-12-25

## 関連コミット
- デバッグ用スキップボタン追加時のコミット
