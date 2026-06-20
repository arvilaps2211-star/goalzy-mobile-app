import '../errors/exceptions.dart';
import '../errors/failures.dart';

typedef Result<T> = ({T? data, Failure? failure});

Failure? mapException(Object e) {
  return switch (e) {
    AuthException(:final message, :final code) => AuthFailure(message, code: code),
    NetworkException(:final message, :final code) => NetworkFailure(message, code: code),
    CacheException(:final message, :final code) => CacheFailure(message, code: code),
    ServerException(:final message, :final code) => ServerFailure(message, code: code),
    _ => ServerFailure(e.toString()),
  };
}
