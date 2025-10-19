import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../models/word_progress.dart';
import '../models/stage_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('word_learning.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const timestampType = 'TIMESTAMP';

    await db.execute('''
      CREATE TABLE users (
        user_id $idType,
        username $textType,
        created_at $timestampType DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        word_id INTEGER PRIMARY KEY AUTOINCREMENT,
        english $textType,
        japanese $textType,
        part_of_speech TEXT,
        stage_id INTEGER,
        difficulty_level INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE word_progress (
        user_id TEXT,
        word_id INTEGER,
        box_level INTEGER DEFAULT 1,
        last_studied_at $timestampType,
        next_review_at $timestampType,
        is_confident BOOLEAN DEFAULT 0,
        correct_count INTEGER DEFAULT 0,
        total_attempts INTEGER DEFAULT 0,
        PRIMARY KEY (user_id, word_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (word_id) REFERENCES words(word_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stage_progress (
        user_id TEXT,
        stage_id INTEGER,
        is_cleared BOOLEAN DEFAULT 0,
        best_score INTEGER,
        cleared_at $timestampType,
        PRIMARY KEY (user_id, stage_id)
      )
    ''');
  }

  Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert(
      'words',
      {
        'english': word.english,
        'japanese': word.japanese,
        'part_of_speech': word.partOfSpeech,
        'stage_id': int.parse(word.stageId),
        'difficulty_level': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Word>> getWordsByStageId(String stageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'stage_id = ?',
      whereArgs: [stageId],
    );

    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i]['word_id'].toString(),
        english: maps[i]['english'],
        japanese: maps[i]['japanese'],
        partOfSpeech: maps[i]['part_of_speech'] ?? '',
        stageId: maps[i]['stage_id'].toString(),
      );
    });
  }

  Future<void> insertOrUpdateWordProgress(WordProgress progress) async {
    final db = await database;
    await db.insert(
      'word_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WordProgress?> getWordProgress(String userId, int wordId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_progress',
      where: 'user_id = ? AND word_id = ?',
      whereArgs: [userId, wordId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return WordProgress.fromMap(maps.first);
  }

  Future<List<WordProgress>> getWordsForReview(String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'word_progress',
      where: 'user_id = ? AND next_review_at <= ? AND box_level < 6',
      whereArgs: [userId, now],
      orderBy: 'next_review_at ASC',
    );

    return List.generate(maps.length, (i) {
      return WordProgress.fromMap(maps[i]);
    });
  }

  Future<void> updateWordProgressAfterAnswer(
    String userId,
    int wordId,
    bool isCorrect,
  ) async {
    final db = await database;
    
    final progress = await getWordProgress(userId, wordId) ??
        WordProgress(
          userId: userId,
          wordId: wordId,
          boxLevel: 1,
          lastStudiedAt: DateTime.now(),
          nextReviewAt: DateTime.now(),
          correctCount: 0,
          totalAttempts: 0,
        );

    final newBoxLevel = isCorrect
        ? (progress.boxLevel < 6 ? progress.boxLevel + 1 : 6)
        : (progress.boxLevel > 1 ? progress.boxLevel - 1 : 1);

    final hoursUntilNextReview = _getHoursForBox(newBoxLevel);
    final nextReviewAt = DateTime.now().add(Duration(hours: hoursUntilNextReview));

    final updatedProgress = progress.copyWith(
      boxLevel: newBoxLevel,
      lastStudiedAt: DateTime.now(),
      nextReviewAt: nextReviewAt,
      correctCount: isCorrect ? progress.correctCount + 1 : progress.correctCount,
      totalAttempts: progress.totalAttempts + 1,
    );

    await insertOrUpdateWordProgress(updatedProgress);
  }

  int _getHoursForBox(int boxLevel) {
    switch (boxLevel) {
      case 1:
        return 12;
      case 2:
        return 48;
      case 3:
        return 96;
      case 4:
        return 168;
      case 5:
        return 336;
      case 6:
        return 999999;
      default:
        return 12;
    }
  }

  Future<void> insertStageProgress(StageProgress progress) async {
    final db = await database;
    await db.insert(
      'stage_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StageProgress?> getStageProgress(String userId, int stageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stage_progress',
      where: 'user_id = ? AND stage_id = ?',
      whereArgs: [userId, stageId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return StageProgress.fromMap(maps.first);
  }

  Future<void> initializeSampleData() async {
    final db = await database;
    
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM words')
    ) ?? 0;
    
    if (count == 0) {
      final sampleWords = [
        {'english': 'apple', 'japanese': 'りんご', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'book', 'japanese': '本', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'cat', 'japanese': '猫', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'dog', 'japanese': '犬', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'eat', 'japanese': '食べる', 'part_of_speech': '動詞', 'stage_id': 1},
        {'english': 'friend', 'japanese': '友達', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'good', 'japanese': '良い', 'part_of_speech': '形容詞', 'stage_id': 1},
        {'english': 'happy', 'japanese': '幸せ', 'part_of_speech': '形容詞', 'stage_id': 1},
        {'english': 'run', 'japanese': '走る', 'part_of_speech': '動詞', 'stage_id': 1},
        {'english': 'school', 'japanese': '学校', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'teacher', 'japanese': '先生', 'part_of_speech': '名詞', 'stage_id': 1},
        {'english': 'water', 'japanese': '水', 'part_of_speech': '名詞', 'stage_id': 1},
      ];

      for (final word in sampleWords) {
        await db.insert('words', word);
      }
    }
    
    final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    ) ?? 0;
    
    if (userCount == 0) {
      await db.insert('users', {
        'user_id': 'default_user',
        'username': 'ゲストユーザー',
      });
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}