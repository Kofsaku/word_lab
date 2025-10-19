class WordProgress {
  final String userId;
  final int wordId;
  final int boxLevel;
  final DateTime lastStudiedAt;
  final DateTime nextReviewAt;
  final bool isConfident;
  final int correctCount;
  final int totalAttempts;

  WordProgress({
    required this.userId,
    required this.wordId,
    required this.boxLevel,
    required this.lastStudiedAt,
    required this.nextReviewAt,
    this.isConfident = false,
    required this.correctCount,
    required this.totalAttempts,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'word_id': wordId,
      'box_level': boxLevel,
      'last_studied_at': lastStudiedAt.toIso8601String(),
      'next_review_at': nextReviewAt.toIso8601String(),
      'is_confident': isConfident ? 1 : 0,
      'correct_count': correctCount,
      'total_attempts': totalAttempts,
    };
  }

  factory WordProgress.fromMap(Map<String, dynamic> map) {
    return WordProgress(
      userId: map['user_id'],
      wordId: map['word_id'],
      boxLevel: map['box_level'],
      lastStudiedAt: DateTime.parse(map['last_studied_at']),
      nextReviewAt: DateTime.parse(map['next_review_at']),
      isConfident: map['is_confident'] == 1,
      correctCount: map['correct_count'],
      totalAttempts: map['total_attempts'],
    );
  }

  WordProgress copyWith({
    String? userId,
    int? wordId,
    int? boxLevel,
    DateTime? lastStudiedAt,
    DateTime? nextReviewAt,
    bool? isConfident,
    int? correctCount,
    int? totalAttempts,
  }) {
    return WordProgress(
      userId: userId ?? this.userId,
      wordId: wordId ?? this.wordId,
      boxLevel: boxLevel ?? this.boxLevel,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      isConfident: isConfident ?? this.isConfident,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }
}