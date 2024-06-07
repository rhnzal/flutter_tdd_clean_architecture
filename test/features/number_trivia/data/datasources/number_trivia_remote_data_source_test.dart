import 'dart:convert';

import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUriEndpoint extends Fake implements Uri {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  setUpAll(() {
    registerFallbackValue(FakeUriEndpoint());
  });

  void setUpMockHttpSuccess() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpFailure() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    var tConcreteNumberTriviaEndpoint = NumberTriviaEndpoint.concreteEndpoint(tNumber);

    test(
      'should perform a GET requried on URL iwth number being the endpoint and with application/json header', 
      () async {
        setUpMockHttpSuccess();

        dataSource.getConcreteNumberTrivia(tNumber);

        verify(() => mockHttpClient.get(tConcreteNumberTriviaEndpoint, headers: {'Content-Type': 'application/json'}));
      }
    );

    test(
      'should return NumberTrivia if response code is 200', 
      () async {
        setUpMockHttpSuccess();

        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        expect(result, tNumberTriviaModel);
      }
    );

    test(
      'should throw ServerException if response code is not 200', 
      () async {
        setUpMockHttpFailure();

        final call = dataSource.getConcreteNumberTrivia;

        expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
      }
    );
  });

  group('getRandomNumberTrivia', () {
    var tRandomTriviaEndpoint = NumberTriviaEndpoint.randomEndpoint();

    test(
      'should perform a GET request on random trivia endpoint and with application/json header', 
      () async {
        setUpMockHttpSuccess();

        dataSource.getRandomNumberTrivia();

        verify(() => mockHttpClient.get(tRandomTriviaEndpoint, headers: {'Content-Type': 'application/json'}));
      }
    );

    test(
      'should return NumberTrivia if response code is 200', 
      () async {
        setUpMockHttpSuccess();

        final result = await dataSource.getRandomNumberTrivia();

        expect(result, tNumberTriviaModel);
      }
    );

    test(
      'should throw ServerException if response code is not 200', 
      () async {
        setUpMockHttpFailure();

        final call = dataSource.getRandomNumberTrivia;

        expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
      }
    );
  });
}