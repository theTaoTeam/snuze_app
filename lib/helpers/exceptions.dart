Exception getFirebaseAuthExceptionWithErrorCode({String code}) {
  Map<String, Exception> _exceptionMap = {
    "Error 17007": new CreateUserException(cause: 'Email already in use.'),
  };

  return _exceptionMap[code];
}

class CreateUserException implements Exception {
  String cause;
  CreateUserException({this.cause});
}

class LoginException implements Exception {
  String cause;
  LoginException({this.cause});
}