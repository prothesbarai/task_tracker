import 'package:flutter/material.dart';
import 'package:task_tracker/widgets/custom_appbar.dart';
import 'package:task_tracker/widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(appBarTitle: "Home",),
      drawer: CustomDrawer(),
    );
  }
}
