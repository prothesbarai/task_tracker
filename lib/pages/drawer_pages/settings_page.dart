import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/models/hive_models/theme_selected_model/theme_selected_model.dart';
import 'package:task_tracker/provider/theme_provider.dart';
import 'package:task_tracker/widgets/custom_appbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  /// >>> Need For Theme Changes Data ==========================================
  String _getThemeItemsName(AppThemeEnum theme){
    switch (theme){
      case AppThemeEnum.system:
        return "System Default";
      case AppThemeEnum.light:
        return "Light Mode";
      case AppThemeEnum.dark:
        return "Dark Mode";
    }
  }
  /// <<< Need For Theme Changes Data ==========================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: CustomAppbar(appBarTitle: "Settings"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // >>> App Preferences ===============================================
          ListTile(
            leading: Icon(Icons.color_lens,color: Theme.of(context).iconTheme.color,size: 35,),
            title: Text("App Preferences",style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
            subtitle: Text("Current : ${_getThemeItemsName(themeProvider.selectedTheme)}",style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),),
            onTap: (){
              AppThemeEnum tempTheme = themeProvider.selectedTheme;
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text("Select Theme"),
                            content: RadioGroup<AppThemeEnum>(
                              groupValue: tempTheme,
                              onChanged: (value) {
                                setState(() {tempTheme = value!;});
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<AppThemeEnum>(value: AppThemeEnum.system,title: const Text("System Default"), activeColor: Colors.blue,),
                                  RadioListTile<AppThemeEnum>(value: AppThemeEnum.light,title: const Text("Light Mode"), activeColor: Colors.blue,),
                                  RadioListTile<AppThemeEnum>(value: AppThemeEnum.dark,title: const Text("Dark Mode"), activeColor: Colors.blue,)
                                ],
                              ),
                            ),
                            actions: [ElevatedButton(onPressed: () {themeProvider.updateTheme(tempTheme);Navigator.pop(context);}, child: const Text("Apply"),),],
                          );
                        },
                    );
                  },
              );
            },
          ),
          // <<< App Preferences ===============================================

        ],
      ),
    );
  }
}
