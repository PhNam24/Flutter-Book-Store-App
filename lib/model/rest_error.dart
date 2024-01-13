class RestError {
  String message;

  RestError({required this.message});

  factory RestError.fromData(String msg) {
    return RestError(
      message: msg,
    );
  }
}