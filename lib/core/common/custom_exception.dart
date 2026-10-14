import 'package:dio/dio.dart';

class ServerError implements Exception {
  String? serverMessage;
  int? statusCode;
  ServerError({this.serverMessage, this.statusCode});
}

class DioHttpException implements Exception {
  DioException? exception;
  DioHttpException(this.exception);
}

class NoInternetError implements Exception {}

class FirebaseAuthError implements Exception {
  String? message;
  FirebaseAuthError(this.message);
}

/// Error coming from Cloud Firestore (permission denied, unavailable, ...).
class FirestoreError implements Exception {
  String? message;
  FirestoreError(this.message);
}
