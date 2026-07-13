class MockUser {
  final String uid;

  const MockUser(this.uid);
}

class AuthService {
  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;

  Future<Object?> signUpWithEmail(String email, String password) async {
    _currentUser = MockUser(email.isNotEmpty ? email : 'local-user');
    return Object();
  }

  Future<Object?> signInWithEmail(String email, String password) async {
    _currentUser = MockUser(email.isNotEmpty ? email : 'local-user');
    return Object();
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
