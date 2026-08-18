import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static GoogleSignIn get instance => _googleSignIn;

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<String?> get idToken async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  static Future<void> signOutSilently() async {
    await _googleSignIn.signOutSilently();
  }
}
