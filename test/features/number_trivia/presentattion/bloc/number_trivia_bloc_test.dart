import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/core/error/failure.dart';
import 'package:flutter_tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_tdd_clean_architecture/core/utils/input_converter.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}


class FakeParams extends Mock implements Params {}

class FakeNoParams extends Mock implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia, 
      getRandomNumberTrivia: mockGetRandomNumberTrivia, 
      inputConverter: mockInputConverter
    );
  });

  setUpAll(() {
    registerFallbackValue(FakeParams());
    registerFallbackValue(NoParams());
  });


  test('initial test should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '123';
    const tNumberParsed = 123;
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 123);

    void setUpMockInputConverterSuccess() => when(() => mockInputConverter.stringToUnsignedInteger(any())).thenReturn(const Right(tNumberParsed));
    void setUpMockGetConcreteNumberTriviaSuccess() => when(() => mockGetConcreteNumberTrivia(any())).thenAnswer((_) async => const Right(tNumberTrivia));


    test(
      'should call input converter validate and convert the string to unsigned integer', 
      () async {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(() => mockInputConverter.stringToUnsignedInteger(any()));

        verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
      }
    );

    test(
      'should emit [Error] when the input is invalid', 
      () async {
        when(() => mockInputConverter.stringToUnsignedInteger(any())).thenReturn(Left(InvalidInputFailure()));
        
        final expected = [const Error(message: INVALID_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        
      }
    );

    test(
      'should get data from the concrete usecase', 
      () async {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(() => mockGetConcreteNumberTrivia(any()));

        verify(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      }
    );

    test(
      'should emit [Loading, Loaded] when the data successfully fetched', 
      () async {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        final expected = [
          Loading(),
          const Loaded(numberTrivia: tNumberTrivia)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      }
    );

    test(
      'should emit [Loading, Error] when the data fail to fetch', 
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer((_) async => Left(ServerFailure()));

        final expected = [
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      }
    );
    
    test(
      'should emit [Loading, Error] when the data fail to fetch from local', 
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer((_) async => Left(CacheFailure()));

        final expected = [
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      }
    );

  });


  group('GetRandomForConcreteNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 123);

    void setUpMockGetRandomNumberTriviaSuccess() => when(() => mockGetRandomNumberTrivia(any())).thenAnswer((_) async => const Right(tNumberTrivia));


    test(
      'should get data from the concrete usecase', 
      () async {
        setUpMockGetRandomNumberTriviaSuccess();

        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));

        verify(() => mockGetRandomNumberTrivia(NoParams()));
      }
    );

    test(
      'should emit [Loading, Loaded] when the data successfully fetched', 
      () async {
        setUpMockGetRandomNumberTriviaSuccess();

        final expected = [
          Loading(),
          const Loaded(numberTrivia: tNumberTrivia)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(GetTriviaForRandomNumber());
      }
    );

    test(
      'should emit [Loading, Error] when the data fail to fetch', 
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer((_) async => Left(ServerFailure()));

        final expected = [
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(GetTriviaForRandomNumber());
      }
    );
    
    test(
      'should emit [Loading, Error] when the data fail to fetch from local', 
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer((_) async => Left(CacheFailure()));

        final expected = [
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE)
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(GetTriviaForRandomNumber());
      }
    );

  });
}