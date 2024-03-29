class ResponseEither {
  final String? message;
  final bool status;
  final dynamic data;
  final StackTrace? stackTrace;

  ResponseEither({
    this.message,
    required this.status,
    this.data,
    this.stackTrace,
  });

  factory ResponseEither.error(String message) => ResponseEither(
        message: message,
        status: false,
      );

  factory ResponseEither.exception(String message, StackTrace stackTrace) =>
      ResponseEither(
        message: message,
        status: false,
        stackTrace: stackTrace,
      );

  factory ResponseEither.success(dynamic data) => ResponseEither(
        data: data,
        status: true,
      );

  @override
  String toString() =>
      'ResponseEither(message: $message, status: $status, data: $data)';
}
