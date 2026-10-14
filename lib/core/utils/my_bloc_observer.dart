import 'dart:developer';

import 'package:bloc/bloc.dart';

class MyBlocObserver implements BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    log('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    log('onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    log('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    log('onTransition -- ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- ${bloc.runtimeType}, $error', stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    log('onClose -- ${bloc.runtimeType}');
  }

  @override
  void onDone(
    Bloc bloc,
    Object? event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log('onDone -- ${bloc.runtimeType}, $event');
  }
}
