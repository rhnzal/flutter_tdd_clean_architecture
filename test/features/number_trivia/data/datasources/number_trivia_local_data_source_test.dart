import 'dart:convert';

import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}


void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    
    test(
      'should return NumberTriviaModel from ShredPreferences when there is one in the cached', 
      () async {
        when(() => mockSharedPreferences.getString(any())).thenReturn(fixture('trivia_cached.json'));

        final result = await dataSource.getLastNumberTrivia();

        verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, tNumberTriviaModel);
      }
    )
    ;
    test(
      'should return CachedException when there is no one in the cached', 
      () async {
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);

        final call = dataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      }
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test trivia');

    test(
      'should call SharedPreferences to cache the data', 
      () async {
        when(() => dataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
        when(() => mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, jsonEncode(tNumberTriviaModel.toJson()))).thenAnswer((_) async => true);

        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        
        final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
        verify(() => mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
      }
    );
  });
}