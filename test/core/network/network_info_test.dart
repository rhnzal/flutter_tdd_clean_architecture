import 'package:flutter_tdd_clean_architecture/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MockInternetConnectionCheker extends Mock implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfoImpl;
  late MockInternetConnectionCheker mockInternetConnectionCheker;

  setUp(() {
    mockInternetConnectionCheker = MockInternetConnectionCheker();
    networkInfoImpl = NetworkInfoImpl(mockInternetConnectionCheker);
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnectionCheker.hasConnection', 
      () async {
        final tHasConnectionFuture = Future.value(true);

        when(() => mockInternetConnectionCheker.hasConnection).thenAnswer((_) => tHasConnectionFuture);

        final result = networkInfoImpl.isConnected;

        verify(() => mockInternetConnectionCheker.hasConnection);
        expect(result, tHasConnectionFuture);
      }
    );
  });
}