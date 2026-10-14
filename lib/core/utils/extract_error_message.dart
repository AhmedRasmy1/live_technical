import '../common/custom_exception.dart';

String extractErrorMessage(Exception? ex) {
  switch (ex) {
    case NoInternetError():
      return 'please check internet connection';
    case ServerError():
      return ex.serverMessage ?? 'something went wrong';
    case DioHttpException():
      return ex.exception?.message ?? 'something went wrong';
    case FirebaseAuthError():
      return ex.message ?? 'something went wrong';
    default:
      return 'something went wrong';
  }
}
