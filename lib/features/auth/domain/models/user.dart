enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.error,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });
}
