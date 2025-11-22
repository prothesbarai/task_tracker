import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleLoginService {
  GoogleLoginService._();
  static final GoogleLoginService instance = GoogleLoginService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: const GoogleSignInParams(
      clientId: '386584413530-0uf2m81qmod3b8otsoeu46qthtg99hqt.apps.googleusercontent.com',
      clientSecret: 'YOUR_CLIENT_SECRET',
      scopes: ['openid', 'email', 'profile'],
    ),
  );

  /// ---------------------------------------------------------
  /// SIGN IN WITH GOOGLE + FIREBASE + FIRESTORE + RETURN USER
  /// ---------------------------------------------------------
  Future signInWithGoogleFirebase() async {
    try {
      final GoogleSignInCredentials? creds = await _googleSignIn.signIn();
      if (creds == null) return null;

      final idToken = creds.idToken;
      final accessToken = creds.accessToken;

      if (idToken == null) throw Exception("Google ID Token is null");

      final oauthCredential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) return null;

      /// >>> Create/Update Firestore User Document
      final userDoc = FirebaseFirestore.instance.collection("users").doc(user.uid);
      await userDoc.set({
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "phone": user.phoneNumber ?? "",
        "photo": user.photoURL ?? "",
        "createAt": FieldValue.serverTimestamp(),
        "provider": "google",
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      debugPrint("Google Login Error: $e");
      return null;
    }
  }

  /// LOGOUT
  Future signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
