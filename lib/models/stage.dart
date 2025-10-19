class Stage {
  final String id;
  final String name;
  final int level;
  final String description;
  final List<String> wordIds;
  bool isCleared;
  double? score;
  DateTime? clearedAt;

  Stage({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.wordIds,
    this.isCleared = false,
    this.score,
    this.clearedAt,
  });

  Stage copyWith({
    String? id,
    String? name,
    int? level,
    String? description,
    List<String>? wordIds,
    bool? isCleared,
    double? score,
    DateTime? clearedAt,
  }) {
    return Stage(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      wordIds: wordIds ?? this.wordIds,
      isCleared: isCleared ?? this.isCleared,
      score: score ?? this.score,
      clearedAt: clearedAt ?? this.clearedAt,
    );
  }
}