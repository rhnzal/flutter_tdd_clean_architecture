import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    required super.text,
    required super.number
  });

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
      text: json['text'], 
      number: json['number'] != null ? (json['number'] as num).toInt() : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'number': number
    };
  }
}