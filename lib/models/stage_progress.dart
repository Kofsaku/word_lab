class StageProgress {
  final String userId;
  final int stageId;
  final bool isCleared;
  final int? bestScore;
  final DateTime? clearedAt;

  StageProgress({
    required this.userId,
    required this.stageId,
    this.isCleared = false,
    this.bestScore,
    this.clearedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'stage_id': stageId,
      'is_cleared': isCleared ? 1 : 0,
      'best_score': bestScore,
      'cleared_at': clearedAt?.toIso8601String(),
    };
  }

  factory StageProgress.fromMap(Map<String, dynamic> map) {
    return StageProgress(
      userId: map['user_id'],
      stageId: map['stage_id'],
      isCleared: map['is_cleared'] == 1,
      bestScore: map['best_score'],
      clearedAt: map['cleared_at'] != null
          ? DateTime.parse(map['cleared_at'])
          : null,
    );
  }

  StageProgress copyWith({
    String? userId,
    int? stageId,
    bool? isCleared,
    int? bestScore,
    DateTime? clearedAt,
  }) {
    return StageProgress(
      userId: userId ?? this.userId,
      stageId: stageId ?? this.stageId,
      isCleared: isCleared ?? this.isCleared,
      bestScore: bestScore ?? this.bestScore,
      clearedAt: clearedAt ?? this.clearedAt,
    );
  }
}