import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../core/utils/arabic_helpers.dart';

/// Question types
enum QuestionType { qcm, fillBlank }

/// Question data model — supports QCM and fill-the-blank
class QuestionModel extends Equatable {
  final String id;
  final String levelId;
  final QuestionType type;
  final String question;
  final int order;

  // QCM fields
  final List<String> options;
  final int correctIndex;

  // Fill-blank fields
  final String sentence;
  final String answer;
  final String hint;
  final int wordIndex;

  const QuestionModel({
    required this.id,
    required this.levelId,
    required this.type,
    required this.question,
    required this.order,
    this.options = const [],
    this.correctIndex = 0,
    this.sentence = '',
    this.answer = '',
    this.hint = '',
    this.wordIndex = -1,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = data['type'] as String? ?? 'qcm';
    return QuestionModel(
      id: doc.id,
      levelId: data['levelId'] as String? ?? '',
      type: typeStr == 'fill_blank' ? QuestionType.fillBlank : QuestionType.qcm,
      question: data['question'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      options: List<String>.from(data['options'] as List? ?? []),
      correctIndex: data['correctIndex'] as int? ?? 0,
      sentence: data['sentence'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      hint: data['hint'] as String? ?? '',
      wordIndex: data['wordIndex'] as int? ?? -1,
    );
  }

  factory QuestionModel.fromMap(Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'qcm';
    return QuestionModel(
      id: data['id'] as String? ?? '',
      levelId: data['levelId'] as String? ?? '',
      type: typeStr == 'fill_blank' ? QuestionType.fillBlank : QuestionType.qcm,
      question: data['question'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      options: List<String>.from(data['options'] as List? ?? []),
      correctIndex: data['correctIndex'] as int? ?? 0,
      sentence: data['sentence'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      hint: data['hint'] as String? ?? '',
      wordIndex: data['wordIndex'] as int? ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type == QuestionType.fillBlank ? 'fill_blank' : 'qcm',
      'question': question,
      'order': order,
      'levelId': levelId,
    };

    if (type == QuestionType.qcm) {
      map['options'] = options;
      map['correctIndex'] = correctIndex;
    } else {
      map['sentence'] = sentence;
      map['answer'] = answer;
      map['hint'] = hint;
      map['wordIndex'] = wordIndex;
    }

    return map;
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'levelId': levelId,
      'type': type == QuestionType.fillBlank ? 'fill_blank' : 'qcm',
      'question': question,
      'order': order,
      'options': options,
      'correctIndex': correctIndex,
      'sentence': sentence,
      'answer': answer,
      'hint': hint,
      'wordIndex': wordIndex,
    };
  }

  /// Correct answer text for display
  String get correctAnswerText {
    if (type == QuestionType.qcm) {
      return (correctIndex >= 0 && correctIndex < options.length)
          ? options[correctIndex]
          : '';
    }
    return answer;
  }

  /// Check if user answer is correct
  bool checkAnswer(dynamic userAnswer) {
    if (type == QuestionType.qcm) {
      return userAnswer == correctIndex;
    }
    // Fill-blank: use Arabic normalization
    final userStr = (userAnswer as String).trim();
    return ArabicHelpers.checkFillBlankAnswer(userStr, answer);
  }

  QuestionModel copyWith({
    String? id,
    String? levelId,
    QuestionType? type,
    String? question,
    int? order,
    List<String>? options,
    int? correctIndex,
    String? sentence,
    String? answer,
    String? hint,
    int? wordIndex,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      type: type ?? this.type,
      question: question ?? this.question,
      order: order ?? this.order,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      sentence: sentence ?? this.sentence,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      wordIndex: wordIndex ?? this.wordIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        levelId,
        type,
        question,
        order,
        options,
        correctIndex,
        sentence,
        answer,
        hint,
        wordIndex,
      ];
}
