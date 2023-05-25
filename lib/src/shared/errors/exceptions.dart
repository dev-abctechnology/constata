class TransferExceptionRepo implements Exception {
  final String message;
  final StackTrace stackTrace;
  TransferExceptionRepo(this.message, this.stackTrace);

  @override
  String toString() {
    return 'TransferExceptionRepo(message: $message, stackTrace: $stackTrace)';
  }
}

class TransferExceptionUseCase implements Exception {
  final String message;
  final StackTrace stackTrace;
  TransferExceptionUseCase(this.message, this.stackTrace);

  @override
  String toString() {
    return 'TransferExceptionUseCase(message: $message, stackTrace: $stackTrace)';
  }
}
