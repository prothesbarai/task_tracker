import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/pages/splash_screen/splash_screen.dart';
import 'package:task_tracker/theme/theme_provider.dart';
import 'package:task_tracker/service/hive_service.dart';
import 'package:task_tracker/theme/custom_app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Hive Initialization
  await HiveService.initHive();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ],
    child: const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: CustomAppTheme.lightTheme,
          darkTheme: CustomAppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: SplashScreen(),
        );
      },
    );
  }
}
