class TestQuestion {
  final String id;
  final String wordId;
  final QuestionType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  String? userAnswer;
  bool? isCorrect;

  TestQuestion({
    required this.id,
    required this.wordId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
  });

  TestQuestion copyWith({
    String? id,
    String? wordId,
    QuestionType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? userAnswer,
    bool? isCorrect,
  }) {
    return TestQuestion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

enum QuestionType {
  multipleChoice,
  textInput,
}