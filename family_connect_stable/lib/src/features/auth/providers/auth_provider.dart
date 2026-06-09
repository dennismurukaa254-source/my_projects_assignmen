import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// AuthState class
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(isLoading: true);
  const AuthState.authenticated(User user) : this(user: user);
  const AuthState.unauthenticated() : this();
  const AuthState.error(String error) : this(error: error);

  bool get isAuthenticated => user != null;
}

// AuthNotifier class
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _checkAuthStatus() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(e.message ?? 'Login failed');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(e.message ?? 'Registration failed');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      state = AuthState.authenticated(userCredential.user!);
    } catch (e) {
      state = AuthState.error('Google sign in failed');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    state = const AuthState.unauthenticated();
  }
}