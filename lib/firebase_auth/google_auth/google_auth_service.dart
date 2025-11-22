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

  Future signInWithGoogleFirebase() async {
    try {
      /// >>> Get Google SignIn credential
      final GoogleSignInCredentials? creds = await _googleSignIn.signIn();
      if (creds == null) {
        /// >>> User SignIn Close or Failed
        return null;
      }

      /// >>> Get idToken or accessToken
      final idToken = creds.idToken;
      final accessToken = creds.accessToken;

      if (idToken == null) {
        throw Exception("Google ID Token is null");
      }

      /// >>> Create Firebase OAuthCredential
      final oauthCredential = GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken);

      /// >>> Sign-In Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return userCredential;
    } catch (e) {
      debugPrint("Error in Google Sign-In: $e");
      rethrow;
    }
  }

  Future signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
