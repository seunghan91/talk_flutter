import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthService {
  final FirebaseAuth _auth;

  FirebasePhoneAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  /// Send verification code via Firebase. Returns verificationId.
  Future<String> sendVerificationCode(String phoneNumber) async {
    final completer = Completer<String>();
    final formattedPhone = _formatPhoneNumber(phoneNumber);

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Android auto-verification - not used on iOS
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      timeout: const Duration(seconds: 60),
    );

    return completer.future;
  }

  /// Verify code and return Firebase ID token.
  Future<String> verifyCodeAndGetToken(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) throw Exception('Firebase 토큰을 가져올 수 없습니다.');
    return idToken;
  }

  /// Sign out from Firebase (called after Rails session is created)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Format Korean phone number to E.164 format
  String _formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return '+82${digits.substring(1)}';
    }
    if (digits.startsWith('82')) {
      return '+$digits';
    }
    return '+82$digits';
  }
}
