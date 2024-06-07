import 'dart:convert';

import 'package:flutter_tdd_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class NumberTriviaRemoteDataSource {
  /// call api http://numbersapi.com/{number} endpoint.
  /// 
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// call api http://numbersapi.com/random/trivia endpoint.
  /// 
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaEndpoint {
  static Uri concreteEndpoint(int number) => Uri.parse('http://numbersapi.com/$number');

  static Uri randomEndpoint() => Uri.parse('http://numbersapi.com/random/trivia');
}



class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client _httpClient;

  NumberTriviaRemoteDataSourceImpl(this._httpClient);

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return await _getTriviaFromUrl(NumberTriviaEndpoint.concreteEndpoint(number));
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return await _getTriviaFromUrl(NumberTriviaEndpoint.randomEndpoint());
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(Uri endpoint) async {
    final response = await _httpClient.get(endpoint, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException();
    }
  }

}