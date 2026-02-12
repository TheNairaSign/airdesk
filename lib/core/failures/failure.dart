class Failure implements Exception {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}


class ServerFailure implements Failure {
  @override
  final String message;

  ServerFailure(this.message);

  @override
  String toString() => 'Server Failure: $message';
}