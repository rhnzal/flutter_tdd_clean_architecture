import 'dart:convert';

import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test text');
  const tNumberTriviaNullModel = NumberTriviaModel(number: null, text: 'Test text');

  test(
    'Should be a sublass of NumberTrivia', 
    () async {
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    }
  );

  group('fromJson', () {
    test(
      'should return a valid model when JSON number is an integer', 
      () async {
        final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));

        final result = NumberTriviaModel.fromJson(jsonMap);
        
        expect(result, tNumberTriviaModel);
      }
    );

    test(
      'should return a valid model when JSON number is regarded as double', 
      () async {
        final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia_double.json'));

        final result = NumberTriviaModel.fromJson(jsonMap);
        
        expect(result, tNumberTriviaModel);
      }
    );

    test(
      'should return a valid model when JSON number is null', 
      () async {
        final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia_null.json'));

        final result = NumberTriviaModel.fromJson(jsonMap);
        
        expect(result, tNumberTriviaNullModel);
      }
    );

  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data', 
      () async {
        final result = tNumberTriviaModel.toJson();

        final expectedMap = {
          'text': 'Test text',
          'number': 1
        };
        expect(result, expectedMap);
      }
    );
  });
}