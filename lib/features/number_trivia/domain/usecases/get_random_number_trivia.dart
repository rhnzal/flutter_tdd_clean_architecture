import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
  final NumberTriviaRepository _repository;

  GetRandomNumberTrivia(this._repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await _repository.getRandomNumberTrivia();
  }
}