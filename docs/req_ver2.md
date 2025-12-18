# ワードLabo 要件定義書

## 1. プロジェクト概要

### 1.1 プロジェクト名
ワードLabo - 英単語トレーニングアプリ

### 1.2 目的
小学5年生から高校生を対象とした、ゲーミフィケーションを活用した英単語学習アプリの開発。ライトナーシステムによる科学的な反復学習と、スワイプ操作による直感的なUIで、継続的な学習を支援する。

### 1.3 対象ユーザー
- **主要ターゲット**: 中学生（13歳前後）
- **対象範囲**: 小学5年生〜高校生（英検5級〜2級レベル）

### 1.4 提供プラットフォーム
- iOS（iPhone/iPad）
- Android（スマートフォン/タブレット）

## 2. 機能要件

### 2.1 画面構成

#### 2.1.1 基本画面（10画面）
| 画面名 | 説明 | 優先度 |
|--------|------|--------|
| スプラッシュ画面 | アプリ起動時のローディング画面 | 必須 |
| ホーム画面 | メインメニュー | 必須 |
| ステージ選択画面 | 学習ステージの選択 | 必須 |
| インプットトレーニング画面 | 単語学習（スワイプ操作） | 必須 |
| チェックタイム画面 | 3種類の確認テスト | 必須 |
| ステージクリアテスト画面 | 総合テスト（12問） | 必須 |
| 結果画面 | テスト結果表示 | 必須 |
| 学習のあしあと画面 | 学習履歴・統計表示 | 必須 |
| 設定画面 | アプリ設定 | 必須 |
| 単語レベル選択画面 | 学習レベルの選択 | Phase2 |

### 2.2 コア機能

#### 2.2.1 ライトナーシステム
**目的**: 科学的な間隔反復による効率的な単語定着

**BOX構成**:
- BOX1: 12時間後に再出題
- BOX2: 48時間後に再出題
- BOX3: 96時間後に再出題
- BOX4: 168時間後に再出題
- BOX5: 336時間後に再出題
- BOX∞: 完全定着（出題除外）

**移動ルール**:
```
正解時: BOX + 1（最大BOX∞）
不正解時: BOX - 1（最小BOX1）
既知語ブースト: BOX + 2（条件付き）
```

#### 2.2.2 インプットトレーニング
**概要**: 6語の英単語を順次表示し、スワイプで学習状態を申告

**機能詳細**:
- 右スワイプ: 「覚えた」→ カード積み上げ
- 左スワイプ: 「要復習」→ 再出題リストへ
- 音声自動再生
- 6語完了でチェックタイムへ自動遷移

#### 2.2.3 チェックタイム
**概要**: 学習した6語を3種類の形式でテスト

**出題形式**:
1. **意味選択問題**: 英単語→日本語訳（4択）
2. **リスニング入力**: 音声→英単語入力
3. **スペリング入力**: 日本語→英単語入力

**入力方式**:
- キーボード入力（標準）
- 手書き入力（Phase2）

#### 2.2.4 ステージクリアテスト
**概要**: 12問の総合テスト

**実装方式**:
- Phase1: 定型英文使用
- Phase2: GPT API による動的生成

### 2.3 データ管理

#### 2.3.1 学習データ
- 単語別学習履歴
- BOXレベル管理
- 次回出題日時
- 正答率統計

#### 2.3.2 ユーザーデータ
- 学習進捗
- ステージクリア状況
- 設定情報

## 3. 非機能要件

### 3.1 パフォーマンス要件
- アプリ起動時間: 3秒以内
- 画面遷移: 0.5秒以内
- スワイプ反応: 即時（60fps）

### 3.2 ユーザビリティ要件
- 直感的なスワイプ操作
- 中学生に適したUI/UX
- オフライン時の基本機能動作

### 3.3 セキュリティ要件
- API キーのサーバー側管理（Cloud Functions）
- ユーザーデータの暗号化保存
- 通信の HTTPS 化

## 4. システム構成

### 4.1 技術スタック

#### フロントエンド
```yaml
Framework: Flutter 3.x
State Management: GetX or Riverpod
Local Storage: SQLite (sqflite)
Animation: Rive / Lottie
```

#### バックエンド（Phase2以降）
```yaml
Cloud Functions: Firebase Functions
Database: Firestore
Authentication: Firebase Auth
API Integration: OpenAI GPT-3.5
```

### 4.2 データベース設計

```sql
-- ユーザーテーブル
CREATE TABLE users (
  user_id TEXT PRIMARY KEY,
  username TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 単語マスタ
CREATE TABLE words (
  word_id INTEGER PRIMARY KEY,
  english TEXT NOT NULL,
  japanese TEXT NOT NULL,
  part_of_speech TEXT,
  stage_id INTEGER,
  difficulty_level INTEGER
);

-- 学習進捗（ライトナー対応）
CREATE TABLE word_progress (
  user_id TEXT,
  word_id INTEGER,
  box_level INTEGER DEFAULT 1,
  last_studied_at TIMESTAMP,
  next_review_at TIMESTAMP,
  is_confident BOOLEAN DEFAULT FALSE,
  correct_count INTEGER DEFAULT 0,
  total_attempts INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, word_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (word_id) REFERENCES words(word_id)
);

-- ステージ進捗
CREATE TABLE stage_progress (
  user_id TEXT,
  stage_id INTEGER,
  is_cleared BOOLEAN DEFAULT FALSE,
  best_score INTEGER,
  cleared_at TIMESTAMP,
  PRIMARY KEY (user_id, stage_id)
);
```

## 5. 開発フェーズ

### Phase 1（MVP）- 4週間
**目標**: 基本学習機能の実装

**実装内容**:
- 基本画面10種
- ライトナーシステム
- インプット→チェック→テストの基本フロー
- ローカルデータ保存
- キーボード入力のみ
- 定型英文でのテスト

### Phase 2 - 3週間
**目標**: 機能拡張とサーバー連携

**実装内容**:
- Cloud Functions 統合
- GPT API による動的問題生成
- 手書き入力機能
- 複数ステージ対応
- データ同期機能

### Phase 3 - 2週間
**目標**: UX向上と収益化

**実装内容**:
- キャラクターアニメーション（Rive）
- 効果音・BGM
- 広告実装
- 課金機能
- 復習トレーニングモード

## 6. 制約事項

### 6.1 技術的制約
- オフライン時は基本機能のみ動作
- 音声データは事前生成したものを使用
- 初期リリースではキーボード入力のみ

### 6.2 リソース制約
- 開発期間: 9週間（Phase1-3合計）
- 初期コンテンツ: 英検5級相当の単語300語

## 7. リスクと対策

| リスク | 影響度 | 対策 |
|--------|--------|------|
| API利用料の高騰 | 高 | 定型文フォールバック実装 |
| ライトナーシステムの複雑性 | 中 | 段階的実装とテスト |
| 手書き認識精度 | 中 | Phase2で検証後実装 |

## 8. 成功指標

### 8.1 定量的指標
- DAU/MAU比: 40%以上
- 7日間継続率: 30%以上
- ステージ完了率: 60%以上

### 8.2 定性的指標
- 直感的な操作性の実現
- 学習効果の実感
- 継続的な学習習慣の形成

## 9. 今後の拡張予定

- 学習管理システム（教育機関向け）
- リスニング強化モード
- AI による個別最適化
- ソーシャル機能（ランキング等）

---

**文書情報**
- バージョン: 1.0
- 作成日: 2024年
- 次回レビュー: Phase1完了時