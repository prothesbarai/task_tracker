import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/pages/splash_screen/splash_screen.dart';
import 'package:task_tracker/theme/theme_provider.dart';
import 'package:task_tracker/service/hive_service.dart';
import 'package:task_tracker/theme/custom_app_theme.dart';
import 'connection_checker/global_network_guard_widget.dart';
import 'connection_checker/network_provider.dart';
import 'firebase_auth/provider/user_hive_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Edge-to-Edge UI + Portrait Mode parallelly
  await Future.wait([
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,]),
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent, systemNavigationBarDividerColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light,),);
  await Firebase.initializeApp();
  // Hive Initialization
  await HiveService.initHive();
  runApp(MultiProvider(
    providers: [
      // >>> Theme UI Mode Change ==============================================
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      // >>> Connection Checker ================================================
      ChangeNotifierProvider(create: (_) => NetworkProvider()),
      // >>> User Data Show ====================================================
      ChangeNotifierProvider(create: (_) => UserHiveProvider()),
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
          // >>> Connection Checker ============================================
          builder: (context, child) {
            // null safety
            if (child == null) return const SizedBox.shrink();
            return GlobalNetworkGuardWidget(child: child);
          },
          // <<< Connection Checker ============================================
          home: SplashScreen(),
        );
      },
    );
  }
}
