import 'package:dartz/dartz.dart';
import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/core/error/failure.dart';
import 'package:flutter_tdd_clean_architecture/core/network/network_info.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main () {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp( () {
      mockRemoteDataSource = MockRemoteDataSource();
      mockLocalDataSource = MockLocalDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo
      );
    }
  );



  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      text: 'Test text', 
      number: tNumber
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    group('check device is connected', () {
      setUp( () {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
        }
      );

      test(
        'should check if the device is online ', 
        () async {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          repository.getConcreteNumberTrivia(tNumber);

          verify(() => mockNetworkInfo.isConnected);
        }
      );
    });


    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful', 
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, Right(tNumberTrivia));
        }
      );

      test(
        'should cache the data locally when the call to remote data source is successful', 
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
          
          await repository.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        } 
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful', 
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenThrow(ServerException());
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure()));
        }
      );


    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      });

      test(
        'should return last locally cached data when the cached data is present', 
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        }
      );

      test(
        'should return CacheFailure when there isno cached data present', 
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        }
      );
    });

  });



  group('getRandomNumberTrivia', () {
    const  tNumberTriviaModel = NumberTriviaModel(
      text: 'Test text', 
      number: 12
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    group('check device is connected', () {
      setUp( () {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        }
      );

      test(
        'should check if the device is online ', 
        () async {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          repository.getRandomNumberTrivia();

          verify(() => mockNetworkInfo.isConnected);
        }
      );
    });


    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful', 
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          final result = await repository.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, Right(tNumberTrivia));
        }
      );

      test(
        'should cache the data locally when the call to remote data source is successful', 
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
          
          await repository.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        } 
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful', 
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());

          final result = await repository.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure()));
        }
      );


    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      });

      test(
        'should return last locally cached data when the cached data is present', 
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        }
      );

      test(
        'should return CacheFailure when there is no cached data present', 
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());

          final result = await repository.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        }
      );
    });

  });
}