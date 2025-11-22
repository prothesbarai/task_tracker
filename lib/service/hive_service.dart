import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../firebase_auth/email_auth/user_hive_model/user_hive_model.dart';
import '../theme/theme_selected_model/theme_selected_model.dart';

class HiveService {
  static Future<void> initHive() async{
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    // Register your adapter
    Hive.registerAdapter(AppThemeEnumAdapter());
    Hive.registerAdapter(UserHiveModelAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox('AppThemeEnumFlag'), // For Light & Dark mode
      Hive.openBox<UserHiveModel>('UserLoginBox'), // Use For Email Authentication
      Hive.openBox('onBoardingAppBox'), // for on boarding
    ]);
  }
}