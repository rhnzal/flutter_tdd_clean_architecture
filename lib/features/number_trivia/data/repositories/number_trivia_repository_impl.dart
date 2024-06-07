import 'package:dartz/dartz.dart';
import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/core/error/failure.dart';
import 'package:flutter_tdd_clean_architecture/core/network/network_info.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';

typedef _ConcreteOrRandomChoose = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository{
  final NumberTriviaRemoteDataSource _remoteDataSource;
  final NumberTriviaLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  NumberTriviaRepositoryImpl({
    required NumberTriviaRemoteDataSource remoteDataSource, 
    required NumberTriviaLocalDataSource localDataSource, 
    required NetworkInfo networkInfo
  }) : 
    _remoteDataSource = remoteDataSource, 
    _localDataSource = localDataSource, 
    _networkInfo = networkInfo;


  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) async {
    return await _getTrivia(() => _remoteDataSource.getConcreteNumberTrivia(number));
    
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => _remoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandomChoose getConcreteOrRandom
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        _localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await _localDataSource.getLastNumberTrivia();
        return Right(localTrivia); 
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

}