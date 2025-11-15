import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/hive_models/theme_selected_model/theme_selected_model.dart';

class HiveService {
  static Future<void> initHive() async{
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    // Register your adapter
    Hive.registerAdapter(AppThemeEnumAdapter());

    // Open boxes
    await Hive.openBox('ThemeBooleanFlag');
  }
}