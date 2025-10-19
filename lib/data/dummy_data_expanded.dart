import '../models/word.dart';
import '../models/stage.dart';
import '../models/test_question.dart';

class DummyDataExpanded {
  // 8段階レベル別単語データ（new_req仕様）
  static final Map<String, List<Word>> wordsByLevel = {
    'elementary_4': [
      Word(id: 'e4_1', english: 'cat', japanese: '猫', partOfSpeech: '名詞', stageId: 'elementary_4'),
      Word(id: 'e4_2', english: 'dog', japanese: '犬', partOfSpeech: '名詞', stageId: 'elementary_4'),
      Word(id: 'e4_3', english: 'red', japanese: '赤い', partOfSpeech: '形容詞', stageId: 'elementary_4'),
      Word(id: 'e4_4', english: 'blue', japanese: '青い', partOfSpeech: '形容詞', stageId: 'elementary_4'),
      Word(id: 'e4_5', english: 'big', japanese: '大きい', partOfSpeech: '形容詞', stageId: 'elementary_4'),
      Word(id: 'e4_6', english: 'eat', japanese: '食べる', partOfSpeech: '動詞', stageId: 'elementary_4'),
    ],
    'elementary_5': [
      Word(id: 'e5_1', english: 'school', japanese: '学校', partOfSpeech: '名詞', stageId: 'elementary_5'),
      Word(id: 'e5_2', english: 'friend', japanese: '友達', partOfSpeech: '名詞', stageId: 'elementary_5'),
      Word(id: 'e5_3', english: 'happy', japanese: '幸せな', partOfSpeech: '形容詞', stageId: 'elementary_5'),
      Word(id: 'e5_4', english: 'play', japanese: '遊ぶ', partOfSpeech: '動詞', stageId: 'elementary_5'),
      Word(id: 'e5_5', english: 'study', japanese: '勉強する', partOfSpeech: '動詞', stageId: 'elementary_5'),
      Word(id: 'e5_6', english: 'teacher', japanese: '先生', partOfSpeech: '名詞', stageId: 'elementary_5'),
    ],
    'elementary_6': [
      Word(id: 'e6_1', english: 'library', japanese: '図書館', partOfSpeech: '名詞', stageId: 'elementary_6'),
      Word(id: 'e6_2', english: 'festival', japanese: '祭り', partOfSpeech: '名詞', stageId: 'elementary_6'),
      Word(id: 'e6_3', english: 'exciting', japanese: '興奮する', partOfSpeech: '形容詞', stageId: 'elementary_6'),
      Word(id: 'e6_4', english: 'discover', japanese: '発見する', partOfSpeech: '動詞', stageId: 'elementary_6'),
      Word(id: 'e6_5', english: 'adventure', japanese: '冒険', partOfSpeech: '名詞', stageId: 'elementary_6'),
      Word(id: 'e6_6', english: 'explore', japanese: '探検する', partOfSpeech: '動詞', stageId: 'elementary_6'),
    ],
    'junior_1': [
      Word(id: 'j1_1', english: 'environment', japanese: '環境', partOfSpeech: '名詞', stageId: 'junior_1'),
      Word(id: 'j1_2', english: 'protect', japanese: '保護する', partOfSpeech: '動詞', stageId: 'junior_1'),
      Word(id: 'j1_3', english: 'serious', japanese: '深刻な', partOfSpeech: '形容詞', stageId: 'junior_1'),
      Word(id: 'j1_4', english: 'solution', japanese: '解決策', partOfSpeech: '名詞', stageId: 'junior_1'),
      Word(id: 'j1_5', english: 'consider', japanese: '考慮する', partOfSpeech: '動詞', stageId: 'junior_1'),
      Word(id: 'j1_6', english: 'effective', japanese: '効果的な', partOfSpeech: '形容詞', stageId: 'junior_1'),
    ],
    'junior_2': [
      Word(id: 'j2_1', english: 'communication', japanese: 'コミュニケーション', partOfSpeech: '名詞', stageId: 'junior_2'),
      Word(id: 'j2_2', english: 'influence', japanese: '影響を与える', partOfSpeech: '動詞', stageId: 'junior_2'),
      Word(id: 'j2_3', english: 'significant', japanese: '重要な', partOfSpeech: '形容詞', stageId: 'junior_2'),
      Word(id: 'j2_4', english: 'opportunity', japanese: '機会', partOfSpeech: '名詞', stageId: 'junior_2'),
      Word(id: 'j2_5', english: 'achieve', japanese: '達成する', partOfSpeech: '動詞', stageId: 'junior_2'),
      Word(id: 'j2_6', english: 'responsible', japanese: '責任のある', partOfSpeech: '形容詞', stageId: 'junior_2'),
    ],
    'junior_3': [
      Word(id: 'j3_1', english: 'democracy', japanese: '民主主義', partOfSpeech: '名詞', stageId: 'junior_3'),
      Word(id: 'j3_2', english: 'participate', japanese: '参加する', partOfSpeech: '動詞', stageId: 'junior_3'),
      Word(id: 'j3_3', english: 'fundamental', japanese: '基本的な', partOfSpeech: '形容詞', stageId: 'junior_3'),
      Word(id: 'j3_4', english: 'constitution', japanese: '憲法', partOfSpeech: '名詞', stageId: 'junior_3'),
      Word(id: 'j3_5', english: 'establish', japanese: '設立する', partOfSpeech: '動詞', stageId: 'junior_3'),
      Word(id: 'j3_6', english: 'legitimate', japanese: '合法的な', partOfSpeech: '形容詞', stageId: 'junior_3'),
    ],
    'high_1': [
      Word(id: 'h1_1', english: 'philosophy', japanese: '哲学', partOfSpeech: '名詞', stageId: 'high_1'),
      Word(id: 'h1_2', english: 'contemplate', japanese: '熟考する', partOfSpeech: '動詞', stageId: 'high_1'),
      Word(id: 'h1_3', english: 'abstract', japanese: '抽象的な', partOfSpeech: '形容詞', stageId: 'high_1'),
      Word(id: 'h1_4', english: 'hypothesis', japanese: '仮説', partOfSpeech: '名詞', stageId: 'high_1'),
      Word(id: 'h1_5', english: 'synthesize', japanese: '統合する', partOfSpeech: '動詞', stageId: 'high_1'),
      Word(id: 'h1_6', english: 'empirical', japanese: '経験的な', partOfSpeech: '形容詞', stageId: 'high_1'),
    ],
    'high_2': [
      Word(id: 'h2_1', english: 'paradigm', japanese: 'パラダイム', partOfSpeech: '名詞', stageId: 'high_2'),
      Word(id: 'h2_2', english: 'substantiate', japanese: '実証する', partOfSpeech: '動詞', stageId: 'high_2'),
      Word(id: 'h2_3', english: 'ubiquitous', japanese: '至る所にある', partOfSpeech: '形容詞', stageId: 'high_2'),
      Word(id: 'h2_4', english: 'methodology', japanese: '方法論', partOfSpeech: '名詞', stageId: 'high_2'),
      Word(id: 'h2_5', english: 'extrapolate', japanese: '推定する', partOfSpeech: '動詞', stageId: 'high_2'),
      Word(id: 'h2_6', english: 'sophisticated', japanese: '洗練された', partOfSpeech: '形容詞', stageId: 'high_2'),
    ],
  };

  // キャラクター（ピコタン）の反応パターン
  static final Map<String, List<String>> characterReactions = {
    'greeting': [
      'こんにちは！今日も頑張ろう！',
      'やっほー！学習の時間だよ！',
      'お疲れさま！一緒に勉強しよう！',
    ],
    'encouragement': [
      'その調子！君ならできるよ！',
      'すごいじゃない！どんどん覚えてるね！',
      'いいペースだよ！継続は力なり！',
    ],
    'correct': [
      'やったね！正解だよ！',
      '素晴らしい！完璧だ！',
      'すごい！その調子で頑張って！',
    ],
    'incorrect': [
      'ドンマイ！次は必ずできるよ！',
      '大丈夫！間違いから学ぶのも大切だよ！',
      'もう一度チャレンジしてみよう！',
    ],
    'completion': [
      'お疲れさま！今日もよく頑張ったね！',
      '素晴らしい成果だよ！君の努力が実ってる！',
      '今日の学習完了！明日も一緒に頑張ろう！',
    ],
    'boost': [
      'わぁ！既知語ブーストだ！君すごいね！',
      'ブースト発動！一気にレベルアップだよ！',
      'すごい自信だ！この調子で行こう！',
    ],
    'perfect': [
      'パーフェクト！完全定着おめでとう！',
      '素晴らしい！この単語はもう完璧だね！',
      'おめでとう！BOX∞達成だよ！',
    ],
  };

  // 8段階レベル定義
  static final Map<String, Map<String, dynamic>> levelDefinitions = {
    'elementary_4': {
      'name': '小学4年生レベル',
      'description': '日常生活でよく使う基本単語',
      'targetWords': 300,
      'icon': '🐱',
      'color': 0xFF4CAF50, // Green
    },
    'elementary_5': {
      'name': '小学5年生レベル',
      'description': '学校生活でよく使う単語',
      'targetWords': 400,
      'icon': '📚',
      'color': 0xFF2196F3, // Blue
    },
    'elementary_6': {
      'name': '小学6年生レベル',
      'description': '少し複雑な概念の単語',
      'targetWords': 500,
      'icon': '🌟',
      'color': 0xFFFF9800, // Orange
    },
    'junior_1': {
      'name': '中学1年生レベル',
      'description': '中学英語の基礎単語',
      'targetWords': 600,
      'icon': '🎯',
      'color': 0xFF9C27B0, // Purple
    },
    'junior_2': {
      'name': '中学2年生レベル',
      'description': '社会問題や抽象概念',
      'targetWords': 750,
      'icon': '🌍',
      'color': 0xFF607D8B, // Blue Grey
    },
    'junior_3': {
      'name': '中学3年生レベル',
      'description': '高度な学術語彙',
      'targetWords': 900,
      'icon': '🏛️',
      'color': 0xFF795548, // Brown
    },
    'high_1': {
      'name': '高校基礎レベル',
      'description': '大学受験基礎語彙',
      'targetWords': 1200,
      'icon': '🎓',
      'color': 0xFF3F51B5, // Indigo
    },
    'high_2': {
      'name': '高校中級レベル',
      'description': '高度なアカデミック語彙',
      'targetWords': 1500,
      'icon': '🔬',
      'color': 0xFF673AB7, // Deep Purple
    },
  };

  // 全単語リスト（既存の互換性維持用）
  static List<Word> get words {
    return wordsByLevel.values.expand((words) => words).toList();
  }

  // ステージ情報（8段階レベル対応）
  static List<Stage> get stages {
    return levelDefinitions.entries.map((entry) {
      final levelId = entry.key;
      final levelData = entry.value;
      
      return Stage(
        id: levelId,
        name: levelData['name'],
        level: _getLevelNumber(levelId),
        description: levelData['description'],
        wordIds: wordsByLevel[levelId]?.map((w) => w.id).toList() ?? [],
      );
    }).toList();
  }

  static int _getLevelNumber(String levelId) {
    final levels = [
      'elementary_4', 'elementary_5', 'elementary_6',
      'junior_1', 'junior_2', 'junior_3',
      'high_1', 'high_2'
    ];
    return levels.indexOf(levelId) + 1;
  }

  // レベル別単語取得
  static List<Word> getWordsByLevel(String levelId) {
    return wordsByLevel[levelId] ?? [];
  }

  // ステージID別単語取得（既存互換性維持）
  static List<Word> getWordsByStageId(String stageId) {
    if (wordsByLevel.containsKey(stageId)) {
      return wordsByLevel[stageId]!;
    }
    // 既存形式の場合
    return words.where((w) => w.stageId == stageId).toList();
  }

  // キャラクター反応取得
  static String getCharacterReaction(String situation, {int? score}) {
    final reactions = characterReactions[situation] ?? ['頑張って！'];
    
    if (situation == 'encouragement' && score != null) {
      if (score >= 90) return 'パーフェクト！君は天才だね！';
      if (score >= 80) return 'すごいじゃない！この調子で行こう！';
      if (score >= 70) return 'いいね！着実に成長してるよ！';
      if (score >= 60) return '頑張ってるね！もう少しだ！';
      return 'ドンマイ！次は必ずできるよ！';
    }
    
    return reactions[DateTime.now().millisecond % reactions.length];
  }

  // テスト問題生成（レベル対応版）
  static List<TestQuestion> generateTestQuestionsByLevel(String levelId) {
    final levelWords = getWordsByLevel(levelId);
    if (levelWords.isEmpty) return [];
    
    List<TestQuestion> questions = [];
    int questionId = 1;

    for (Word word in levelWords.take(6)) {
      // 意味選択問題（4択）
      questions.add(TestQuestion(
        id: 'q${questionId++}',
        wordId: word.id,
        type: QuestionType.multipleChoice,
        question: '"${word.english}" の意味は？',
        options: _generateOptionsForLevel(word.japanese, true, levelId),
        correctAnswer: word.japanese,
      ));

      // 英単語入力問題
      questions.add(TestQuestion(
        id: 'q${questionId++}',
        wordId: word.id,
        type: QuestionType.textInput,
        question: '"${word.japanese}" を英語で入力してください',
        options: [],
        correctAnswer: word.english,
      ));
    }

    return questions;
  }

  static List<String> _generateOptionsForLevel(String correct, bool isJapanese, String levelId) {
    List<String> options = [correct];
    
    // レベル別の誤答選択肢
    final levelWords = wordsByLevel[levelId] ?? [];
    final similarWords = levelWords
        .where((w) => (isJapanese ? w.japanese : w.english) != correct)
        .map((w) => isJapanese ? w.japanese : w.english)
        .toList();
    
    similarWords.shuffle();
    
    // 同レベルから2つ、他レベルから1つの誤答を生成
    for (String option in similarWords.take(2)) {
      if (options.length < 4) {
        options.add(option);
      }
    }
    
    // 不足分は汎用誤答で補完
    if (options.length < 4) {
      final genericOptions = isJapanese 
          ? ['別の意味1', '別の意味2', '別の意味3']
          : ['other1', 'other2', 'other3'];
      
      for (String option in genericOptions) {
        if (options.length < 4) {
          options.add(option);
        }
      }
    }
    
    options.shuffle();
    return options;
  }

  // レベル情報取得
  static Map<String, dynamic>? getLevelInfo(String levelId) {
    return levelDefinitions[levelId];
  }

  // 既存メソッドの互換性維持
  static List<TestQuestion> generateTestQuestions(List<String> wordIds) {
    return generateTestQuestionsByLevel('elementary_5'); // デフォルト
  }

  static Word? getWordById(String id) {
    try {
      return words.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  static Stage? getStageById(String id) {
    try {
      return stages.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Word> getReviewWords() {
    return words.where((w) => w.isInReviewList).toList();
  }

  // 単語出題アルゴリズム（new_req仕様）
  static List<Word> getWordsForSession(String levelId, {int maxWords = 6}) {
    // その日の復習対象単語を抽出（BOX期限到達）- ダミー実装
    final reviewWords = getReviewWordsForLevel(levelId);
    
    List<Word> sessionWords = [];
    
    // 復習単語を優先
    sessionWords.addAll(reviewWords.take(maxWords));
    
    // 6語に満たない場合、新出単語を補充
    if (sessionWords.length < maxWords) {
      final newWords = getNewWordsForLevel(levelId);
      final needed = maxWords - sessionWords.length;
      sessionWords.addAll(newWords.take(needed));
    }
    
    return sessionWords;
  }

  static List<Word> getReviewWordsForLevel(String levelId) {
    // ダミー：復習対象単語（実際はBOX期限で判定）
    final levelWords = getWordsByLevel(levelId);
    return levelWords.where((w) => DateTime.now().millisecond % 3 == 0).toList();
  }

  static List<Word> getNewWordsForLevel(String levelId) {
    // ダミー：新出単語（実際は未学習単語）
    final levelWords = getWordsByLevel(levelId);
    return levelWords.where((w) => !w.isMemorized).toList();
  }
}