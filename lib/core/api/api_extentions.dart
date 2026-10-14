import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../common/api_result.dart';
import '../common/custom_exception.dart';

Future<Result<T>> executeApi<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return Success(result);
  } on TimeoutException {
    return Fail(NoInternetError());
  } on IOException {
    return Fail(NoInternetError());
  } on DioException catch (ex) {
    dynamic message;
    final data = ex.response?.data;
    if (data is Map) {
      message = data['message'];
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) message = decoded['message'];
      } catch (_) {}
    }
    message ??= 'حدث خطأ غير متوقع';
    log(message.toString());
    if (ex.response != null) {
      return Fail(
        ServerError(
          statusCode: ex.response?.statusCode,
          serverMessage: message.toString(),
        ),
      );
    }
    return Fail(DioHttpException(ex));
  } on Exception catch (ex) {
    return Fail(ex);
  }
}
