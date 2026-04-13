import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google — using new google_sign_in v7 API
  Future<User?> signInWithGoogle() async {
    try {
      // v7: initialize first, then authenticate
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();


      // Request authorization to get tokens for Firebase
      var googleAuth = await googleUser.authorizationClient.authorizationForScopes(
        ['email', 'profile', 'openid'],
      );
      // Fallback if user interaction is needed
      googleAuth ??= await googleUser.authorizationClient.authorizeScopes(
        ['email', 'profile', 'openid'],
      );

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user to Firestore on first login
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'displayName': user.displayName ?? googleUser.displayName ?? 'User',
            'email': user.email ?? googleUser.email,
            'photoURL': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Attempt to sign out of GoogleSignIn instance if initialized
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
