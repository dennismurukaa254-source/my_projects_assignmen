import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:family_connect_stable/src/features/auth/presentation/login_screen.dart';
import 'package:family_connect_stable/src/features/auth/providers/auth_provider.dart';

// ============================================================================
// Fake User that satisfies the firebase_auth.User interface
// ============================================================================
class FakeUser implements firebase_auth.User {
  @override
  String get uid => 'fake_uid';
  @override
  String? get displayName => 'Test User';
  @override
  String? get email => 'test@example.com';
  @override
  bool get emailVerified => true;
  @override
  bool get isAnonymous => false;
  @override
  String? get phoneNumber => null;
  @override
  String? get photoURL => null;
  @override
  List<firebase_auth.UserInfo> get providerData => [];
  @override
  String get refreshToken => '';
  @override
  String get tenantId => '';
  @override
  Future<void> delete() => Future.value();
  @override
  Future<String> getIdToken([bool forceRefresh = false]) => Future.value('token');
  @override
  Future<String?> getIdTokenResult([bool forceRefresh = false]) => Future.value('token');
  @override
  Future<void> linkWithCredential(firebase_auth.AuthCredential credential) => Future.value();
  @override
  Future<firebase_auth.UserCredential> linkWithPopup(firebase_auth.AuthProvider provider) =>
      Future.value(firebase_auth.UserCredential());
  @override
  Future<void> linkWithRedirect(firebase_auth.AuthProvider provider) => Future.value();
  @override
  Future<void> reauthenticateWithCredential(firebase_auth.AuthCredential credential) => Future.value();
  @override
  Future<void> reload() => Future.value();
  @override
  Future<void> sendEmailVerification() => Future.value();
  @override
  Future<void> sendEmailVerificationWithSettings(firebase_auth.ActionCodeSettings actionCodeSettings) =>
      Future.value();
  @override
  Future<void> unlink(String providerId) => Future.value();
  @override
  Future<void> updateDisplayName(String? displayName) => Future.value();
  @override
  Future<void> updateEmail(String newEmail) => Future.value();
  @override
  Future<void> updatePassword(String newPassword) => Future.value();
  @override
  Future<void> updatePhoneNumber(firebase_auth.PhoneAuthCredential phoneCredential) => Future.value();
  @override
  Future<void> updatePhotoURL(String? photoURL) => Future.value();
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) => Future.value();
  @override
  firebase_auth.User? get user => this;
}

// ============================================================================
// Fake AuthNotifier (does not call any real Firebase methods)
// ============================================================================
class FakeAuthNotifier extends StateNotifier<AuthState> {
  FakeAuthNotifier() : super(const AuthState.unauthenticated());

  void simulateLogin() {
    state = AuthState.authenticated(FakeUser());
  }

  void simulateLogout() {
    state = const AuthState.unauthenticated();
  }
}

void main() {
  testWidgets('LoginScreen displays email and password fields', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => FakeAuthNotifier()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify the login screen contains the expected widgets
    expect(find.byType(TextField), findsNWidgets(2)); // email + password
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}