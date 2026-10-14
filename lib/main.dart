import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'core/di/di.dart';
import 'core/resources/color_manager.dart';
import 'core/utils/cashed_data_shared_preferences.dart';
import 'core/utils/my_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  // Add `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
  // here once a Firebase feature is requested.
  await CacheService.cacheInitialization();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorManager.primary),
        scaffoldBackgroundColor: ColorManager.background,
      ),
      // Replace with the first feature screen once a feature is requested.
      home: const Scaffold(),
    );
  }
}
