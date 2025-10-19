class Word {
  final String id;
  final String english;
  final String japanese;
  final String partOfSpeech;
  final String stageId;
  bool isMemorized;
  bool isInReviewList;
  DateTime? lastStudiedAt;

  Word({
    required this.id,
    required this.english,
    required this.japanese,
    required this.partOfSpeech,
    required this.stageId,
    this.isMemorized = false,
    this.isInReviewList = false,
    this.lastStudiedAt,
  });

  Word copyWith({
    String? id,
    String? english,
    String? japanese,
    String? partOfSpeech,
    String? stageId,
    bool? isMemorized,
    bool? isInReviewList,
    DateTime? lastStudiedAt,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      japanese: japanese ?? this.japanese,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      stageId: stageId ?? this.stageId,
      isMemorized: isMemorized ?? this.isMemorized,
      isInReviewList: isInReviewList ?? this.isInReviewList,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }
}