import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static Future<void> googleLogin() async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn signIn = GoogleSignIn.instance;
  }
}