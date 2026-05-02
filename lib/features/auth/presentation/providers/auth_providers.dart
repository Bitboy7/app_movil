import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';
import '../../../settings/presentation/providers/profile_providers.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final repository = _ref.read(authRepositoryProvider);

    // Check current user immediately
    final currentUser = repository.currentUser;
    if (currentUser != null) {
      state = AuthState(status: AuthStatus.authenticated, user: currentUser);
      Future.microtask(_syncToProfileProviders);
    }

    // Listen to auth state changes
    repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        Future.microtask(_syncToProfileProviders);
        _persistUser(user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
        _clearPersistedUser();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signInWithGoogle();
      if (user == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmailAndPassword(email, password);
      if (user == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    final repository = _ref.read(authRepositoryProvider);
    await repository.signOut();

    Future.microtask(() {
      _ref.read(userNameProvider.notifier).state = 'Usuario';
      _ref.read(userEmailProvider.notifier).state = 'usuario@bibu.app';
      _ref.read(userPhotoUrlProvider.notifier).state = null;
    });

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _syncToProfileProviders() {
    if (state.user != null) {
      _ref.read(userNameProvider.notifier).state = state.user!.name;
      _ref.read(userEmailProvider.notifier).state = state.user!.email;
      _ref.read(userPhotoUrlProvider.notifier).state = state.user!.photoUrl;
    }
  }

  Future<void> _persistUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'logged_in');
    await prefs.setString('auth_id', user.id);
    await prefs.setString('auth_name', user.name);
    await prefs.setString('auth_email', user.email);
    if (user.photoUrl != null) {
      await prefs.setString('user_photo_url', user.photoUrl!);
    }
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }

  Future<void> _clearPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_id');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');
  }
}
