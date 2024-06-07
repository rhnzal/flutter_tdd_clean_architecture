import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tdd_clean_architecture/core/error/failure.dart';
import 'package:flutter_tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_tdd_clean_architecture/core/utils/input_converter.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_FAILURE_MESSAGE = 'Invalid Failure - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia, 
    required this.getRandomNumberTrivia, 
    required this.inputConverter
  }) : super(Empty()) {

    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inpuEither = inputConverter.stringToUnsignedInteger(event.numberString);

      await inpuEither.fold(
        (failure) {
          emit(const Error(message: INVALID_FAILURE_MESSAGE));
        }, 
        (integer) async {
          emit(Loading());
          final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
          
          _eitherLoadedOrErrorState(failureOrTrivia, emit);
        }
      );
    });


    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      
      _eitherLoadedOrErrorState(failureOrTrivia, emit);
    });
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia, Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold(
      (failure) {
        emit(Error(message: _mapFailureToMessage(failure)));
      }, 
      (trivia) {
        emit(Loaded(numberTrivia: trivia));
      }
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch(failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
