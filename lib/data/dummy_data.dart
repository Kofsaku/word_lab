import '../models/word.dart';
import '../models/stage.dart';
import '../models/test_question.dart';

class DummyData {
  static final List<Word> words = [
    // Stage 1 words
    Word(
      id: 'w1',
      english: 'apple',
      japanese: 'りんご',
      partOfSpeech: '名詞',
      stageId: 's1',
    ),
    Word(
      id: 'w2',
      english: 'run',
      japanese: '走る',
      partOfSpeech: '動詞',
      stageId: 's1',
    ),
    Word(
      id: 'w3',
      english: 'happy',
      japanese: '幸せな',
      partOfSpeech: '形容詞',
      stageId: 's1',
    ),
    Word(
      id: 'w4',
      english: 'book',
      japanese: '本',
      partOfSpeech: '名詞',
      stageId: 's1',
    ),
    Word(
      id: 'w5',
      english: 'study',
      japanese: '勉強する',
      partOfSpeech: '動詞',
      stageId: 's1',
    ),
    Word(
      id: 'w6',
      english: 'beautiful',
      japanese: '美しい',
      partOfSpeech: '形容詞',
      stageId: 's1',
    ),
    // Stage 2 words
    Word(
      id: 'w7',
      english: 'computer',
      japanese: 'コンピューター',
      partOfSpeech: '名詞',
      stageId: 's2',
    ),
    Word(
      id: 'w8',
      english: 'develop',
      japanese: '開発する',
      partOfSpeech: '動詞',
      stageId: 's2',
    ),
    Word(
      id: 'w9',
      english: 'important',
      japanese: '重要な',
      partOfSpeech: '形容詞',
      stageId: 's2',
    ),
    Word(
      id: 'w10',
      english: 'project',
      japanese: 'プロジェクト',
      partOfSpeech: '名詞',
      stageId: 's2',
    ),
    Word(
      id: 'w11',
      english: 'create',
      japanese: '作成する',
      partOfSpeech: '動詞',
      stageId: 's2',
    ),
    Word(
      id: 'w12',
      english: 'successful',
      japanese: '成功した',
      partOfSpeech: '形容詞',
      stageId: 's2',
    ),
    // Stage 3 words
    Word(
      id: 'w13',
      english: 'innovation',
      japanese: '革新',
      partOfSpeech: '名詞',
      stageId: 's3',
    ),
    Word(
      id: 'w14',
      english: 'collaborate',
      japanese: '協力する',
      partOfSpeech: '動詞',
      stageId: 's3',
    ),
    Word(
      id: 'w15',
      english: 'efficient',
      japanese: '効率的な',
      partOfSpeech: '形容詞',
      stageId: 's3',
    ),
    Word(
      id: 'w16',
      english: 'technology',
      japanese: '技術',
      partOfSpeech: '名詞',
      stageId: 's3',
    ),
    Word(
      id: 'w17',
      english: 'implement',
      japanese: '実装する',
      partOfSpeech: '動詞',
      stageId: 's3',
    ),
    Word(
      id: 'w18',
      english: 'comprehensive',
      japanese: '包括的な',
      partOfSpeech: '形容詞',
      stageId: 's3',
    ),
  ];

  static final List<Stage> stages = [
    Stage(
      id: 's1',
      name: 'ステージ 1',
      level: 1,
      description: '基本的な英単語を学習しよう',
      wordIds: ['w1', 'w2', 'w3', 'w4', 'w5', 'w6'],
    ),
    Stage(
      id: 's2',
      name: 'ステージ 2',
      level: 2,
      description: 'ビジネス基礎単語を学習しよう',
      wordIds: ['w7', 'w8', 'w9', 'w10', 'w11', 'w12'],
    ),
    Stage(
      id: 's3',
      name: 'ステージ 3',
      level: 3,
      description: '上級ビジネス単語を学習しよう',
      wordIds: ['w13', 'w14', 'w15', 'w16', 'w17', 'w18'],
    ),
  ];

  static List<TestQuestion> generateTestQuestions(List<String> wordIds) {
    List<TestQuestion> questions = [];
    int questionId = 1;

    for (String wordId in wordIds.take(6)) {
      final word = words.firstWhere((w) => w.id == wordId);
      
      // 意味選択問題（4択）
      questions.add(TestQuestion(
        id: 'q${questionId++}',
        wordId: wordId,
        type: QuestionType.multipleChoice,
        question: '"${word.english}" の意味は？',
        options: _generateOptions(word.japanese, true),
        correctAnswer: word.japanese,
      ));

      // 英単語入力問題
      questions.add(TestQuestion(
        id: 'q${questionId++}',
        wordId: wordId,
        type: QuestionType.textInput,
        question: '"${word.japanese}" を英語で入力してください',
        options: [],
        correctAnswer: word.english,
      ));
    }

    return questions;
  }

  static List<String> _generateOptions(String correct, bool isJapanese) {
    List<String> options = [correct];
    
    if (isJapanese) {
      final dummyOptions = [
        '机', '椅子', '水', '空', '山', '海', '風', '光',
        '音', '色', '形', '大きい', '小さい', '新しい', '古い',
        '食べる', '飲む', '見る', '聞く', '話す', '書く', '読む',
      ];
      
      dummyOptions.shuffle();
      for (String option in dummyOptions) {
        if (option != correct && options.length < 4) {
          options.add(option);
        }
      }
    } else {
      final dummyOptions = [
        'desk', 'chair', 'water', 'sky', 'mountain', 'sea', 'wind', 'light',
        'sound', 'color', 'shape', 'big', 'small', 'new', 'old',
        'eat', 'drink', 'see', 'hear', 'speak', 'write', 'read',
      ];
      
      dummyOptions.shuffle();
      for (String option in dummyOptions) {
        if (option != correct && options.length < 4) {
          options.add(option);
        }
      }
    }
    
    options.shuffle();
    return options;
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

  static List<Word> getWordsByStageId(String stageId) {
    return words.where((w) => w.stageId == stageId).toList();
  }

  static List<Word> getReviewWords() {
    return words.where((w) => w.isInReviewList).toList();
  }
}