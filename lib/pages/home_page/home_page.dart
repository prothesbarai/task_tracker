import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/widgets/custom_appbar.dart';
import 'package:task_tracker/widgets/custom_drawer.dart';

import '../../firebase_auth/email_auth/provider/user_hive_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserHiveProvider>(context);
    return Scaffold(
      appBar: CustomAppbar(appBarTitle: "Home",),
      drawer: CustomDrawer(),
      body: SafeArea(
          child: Column(
            children: [
              Text("${userProvider.user?.uid}"),
              Text("${userProvider.user?.name}"),
              Text("${userProvider.user?.email}"),
              Text("${userProvider.user?.phone}"),
              Text("${userProvider.user?.createAt}"),
            ],
          )
      ),
    );
  }
}
