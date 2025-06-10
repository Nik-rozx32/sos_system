import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up (Creates a new account)
  Future<bool> signup({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Account created successfully
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Email is already in use. Please log in instead.");
      } else {
        print("Signup error: ${e.message}");
      }
      return false; // Failed to sign up
    }
  }

  // Log In (Checks if user exists)
  Future<bool> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Successfully logged in
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        print("Incorrect password. Please try again.");
      } else if (e.code == 'user-not-found') {
        print("No account found for this email.");
      } else {
        print("Login error: ${e.message}");
      }
      return false; // Failed to log in
    }
  }
}

