import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../firebase_auth/user_hive_model/user_hive_model.dart';
import '../theme/theme_selected_model/theme_selected_model.dart';

class HiveService {
  static Future<void> initHive() async{
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    // Register your adapter
    Hive.registerAdapter(AppThemeEnumAdapter());
    Hive.registerAdapter(UserHiveModelAdapter());

    // Open boxes
    await Hive.openBox('AppThemeEnumFlag');
    await Hive.openBox<UserHiveModel>('UserLoginBox');
    await Hive.openBox('onBoardingAppBox');
  }
}