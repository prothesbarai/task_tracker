import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/pages/home_page/home_page.dart';
import 'package:task_tracker/utils/constant/app_colors.dart';
import '../../firebase_auth/login_page.dart';
import '../../firebase_auth/provider/user_hive_provider.dart';
import '../../onboarding/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation<double> _animation;


  /// >>>> Text Typed Writer Effects ===========================================
  final String _fullText = "Task Tracker";
  String _currentText = "";
  int _charIndex = 0;
  late Timer _textTimer;
  /// <<<< Text Typed Writer Effects ===========================================


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this,duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8,end: 1.2).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _textTimer = Timer.periodic(const Duration(milliseconds: 150), (timer){
      if(_charIndex < _fullText.length){
        setState(() {
          _currentText += _fullText[_charIndex];
          _charIndex++;
        });
      }else{
        _textTimer.cancel();

        Future.microtask(() {
          if(!mounted) return;
          final userProvider = Provider.of<UserHiveProvider>(context, listen: false);
          final box = Hive.box("onBoardingAppBox");
          bool seen = box.get("onboarding_seen", defaultValue: false);

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;

            if (userProvider.user != null && userProvider.user?.regLoginFlag == true) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
            } else {
              if (seen) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingPage()));
              }
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5),),],),
                child: const Icon(Icons.task_alt, size: 80, color: Colors.blue,),
              ),
              const SizedBox(height: 20),
              Text(_currentText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2,),),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
