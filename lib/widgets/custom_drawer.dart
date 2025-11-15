import 'package:flutter/material.dart';
import '../pages/drawer_pages/settings_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                            Text("Owner Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text("prothes16@email.com", style: TextStyle(fontSize: 13)),
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
              )
              /// <<< =================== Drawer Items =========================
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
/// <<< ========================= Drawer Item Widget =========================
}
