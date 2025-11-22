import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/theme/theme_provider.dart';
import '../firebase_auth/email_auth/login_page.dart';
import '../firebase_auth/email_auth/provider/user_hive_provider.dart';
import '../firebase_auth/google_auth/google_auth_service.dart';
import '../pages/drawer_pages/settings_page.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {


  /// >>> After Logout Remove Hive And Show Login Page =========================
  void _navigateLoginPage(){
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,);
  }
  /// <<< After Logout Remove Hive And Show Login Page =========================

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserHiveProvider>(context,listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Drawer(
      child: SafeArea(
          child: Column(
            children: [
              /// >>> =================== Drawer Header ========================
              GestureDetector(
                onTap: () {},
                child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 35, backgroundColor: Colors.white,),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userProvider.user?.name != null ? "${userProvider.user?.name}" : "User Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(userProvider.user?.email != null ? "${userProvider.user?.email}" : "User Email", style: TextStyle(fontSize: 13),overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              /// <<< =================== Drawer Header ========================

              /// >>> =================== Drawer Items =========================
              Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildItem(context, "Settings", Icons.settings_outlined, onTap: (){Navigator.pop(context);Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));}),
                    ],
                  )
              ),
              /// <<< =================== Drawer Items =========================


              /// >>> =================== Logout Bottom ==========================
              Divider(),
              ListTile(
                leading: Icon(Icons.logout,size: 30),
                title: Text("Logout", style: TextStyle(fontSize: 15),),
                onTap: () {
                  // Logout logic
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                        ElevatedButton(
                            onPressed: () async{
                              await Future.wait([
                                GoogleLoginService.instance.signOut(),
                                userProvider.clearUserData(),
                                themeProvider.clearTheme(),
                              ]);
                              if(mounted) _navigateLoginPage();
                            },
                            child: const Text("Logout")
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              /// <<< =================== Logout Bottom ==========================
            ],
          )
      ),
    );
  }

  /// >>> ========================= Drawer Item Widget =========================
  Widget _buildItem(BuildContext context, String title, IconData icon, {bool showSwitch = false, bool switchValue = false, ValueChanged<bool>? onSwitchChanged, VoidCallback? onTap,}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 28,),
      title: Text(title,),
      trailing: showSwitch ? Switch(value: switchValue, onChanged: onSwitchChanged, activeThumbColor: Colors.white, inactiveThumbColor: Colors.grey,) : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
    );
  }
}
