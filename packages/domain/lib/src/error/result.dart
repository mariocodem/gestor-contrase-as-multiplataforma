import 'app_error.dart';

/// The outcome of a use case: a value, or the [AppError] that explains why there isn't one.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// The value, or null on failure.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  AppError? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// The value, or throws the failure as an [AppException].
  T get valueOrThrow => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => throw AppException(error),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Success<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;

  @override
  bool operator ==(Object other) => other is Failure<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Runs [block], turning an [AppException] into its failure and anything else into
/// [AppError.unexpected]; nothing escapes as an exception.
Future<Result<T>> resultOf<T>(Future<T> Function() block) async {
  try {
    return Success(await block());
  } on AppException catch (e) {
    return Failure(e.error);
  } catch (e) {
    return Failure(AppError.unexpected(e.toString()));
  }
}

/// The synchronous counterpart of [resultOf].
Result<T> resultOfSync<T>(T Function() block) {
  try {
    return Success(block());
  } on AppException catch (e) {
    return Failure(e.error);
  } catch (e) {
    return Failure(AppError.unexpected(e.toString()));
  }
}
