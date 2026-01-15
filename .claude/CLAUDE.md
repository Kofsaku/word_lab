# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Word Learning App (ワードLabo) - A gamified English vocabulary learning app for Japanese middle/high school students using Lichtner spacing system. Flutter cross-platform app targeting iOS and Android.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run on emulator/device
flutter run
flutter run -d emulator-5554   # Specific Android emulator

# Build
flutter build apk              # Android
flutter build ios              # iOS

# Code quality
flutter analyze
dart format lib/
```

## Architecture

### Entry Point & Routing
`main.dart` uses `onGenerateRoute()` with named routes. Key routes:
- `/home` - Main hub
- `/input-training` - Card swipe training (args: stageId)
- `/check-time-v2` - Quick tests before final exam
- `/interest-input` - User interest for personalized questions
- `/stage-test` - Final 12-question test (args: stageId, checkTimeResults, userInterest)

### Service Layer (Singletons)
- `DatabaseHelper.instance` - SQLite with Lichtner box system
- `AudioService.instance` - TTS & sound effects with fallback chain
- `HandwritingRecognitionService.instance` - Google ML Kit integration

### Model Pattern
All models use immutable pattern with `copyWith()` and `fromMap()`/`toMap()` for database operations.

### State Management
Direct `StatefulWidget` + `setState()`. Animation-heavy screens use `TickerProviderStateMixin` for multiple `AnimationController`s.

## Key Components

### Lichtner Spacing System (database_helper.dart)
Tracks word progress in boxes 1-6:
- Box levels determine review intervals (12hrs → 336hrs)
- `word_progress` table: box_level, next_review_at, correctCount, totalAttempts

### Training Flow
1. **Input Training** - Card swipe (left=unknown, right=known) with Rive character
2. **Check Time V2** - 3 quick tests (multiple choice, text input, handwriting)
3. **Interest Input** - Collects user interests for context
4. **Stage Test** - 12 questions: 6 English→Japanese, 6 Japanese→English

### Audio System (audio_service.dart)
Fallback hierarchy: Asset files → Flutter TTS → System sounds → Haptic feedback

## Theme

Pastel color palette defined in `app_colors.dart`:
- Background: Pastel Cream (#F5F0E8)
- Primary: Pastel Pink (#E8B4B8)
- Accent: Pastel Mint (#B8D8D8)
- Correct: Mint, Incorrect: Pink

## Key Dependencies

- `sqflite` - Local database (Lichtner system)
- `flutter_tts` - Text-to-speech
- `google_ml_kit` - Handwriting recognition
- `rive` - Character animations
- `flutter_card_swiper` - Card swipe UI

## Conventions

- Screen structure: `build()` with private `_buildXxx()` helper methods
- Japanese language throughout UI and comments
- Multiple animation controllers per screen are common
- Services follow singleton pattern with `instance` getter

## Issue Tracking

開発中に発見した問題や修正が必要な箇所は `issue/` ディレクトリに記録する。

### ディレクトリ構造
```
issue/
├── README.md                          # 概要とissue一覧
└── {番号}_{概要}.md                    # 個別のissue
```

### 運用ルール
1. 問題を発見したら `issue/{番号}_{概要}.md` として記録
2. 各issueにはステータス、優先度、対象ファイル、修正方法を記載
3. `// TODO: デバッグ用 - リリース時に削除` などのマーカーを使用
4. リリース前に未対応issueを確認

### 検索コマンド
```bash
# デバッグ用コードを検索
grep -rn "TODO: デバッグ用" lib/

# 全TODOを検索
grep -rn "TODO" lib/
```
