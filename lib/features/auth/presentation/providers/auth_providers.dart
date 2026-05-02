import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/user.dart';
import '../../../settings/presentation/providers/profile_providers.dart';

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
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final name = prefs.getString('user_name') ?? prefs.getString('auth_name') ?? 'Usuario';
      final email = prefs.getString('user_email') ?? prefs.getString('auth_email') ?? '';
      final photoUrl = prefs.getString('user_photo_url');
      final user = User(
        id: prefs.getString('auth_id') ?? '',
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      _syncToProfileProviders();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    await Future.delayed(const Duration(milliseconds: 1500));

    final user = User(
      id: const Uuid().v4(),
      name: email.split('@').first,
      email: email,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'logged_in');
    await prefs.setString('auth_id', user.id);
    await prefs.setString('auth_name', user.name);
    await prefs.setString('auth_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);

    state = AuthState(status: AuthStatus.authenticated, user: user);
    _syncToProfileProviders();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_id');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');

    _ref.read(userNameProvider.notifier).state = 'Usuario';
    _ref.read(userEmailProvider.notifier).state = 'usuario@bibu.app';
    _ref.read(userPhotoUrlProvider.notifier).state = null;

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _syncToProfileProviders() {
    if (state.user != null) {
      _ref.read(userNameProvider.notifier).state = state.user!.name;
      _ref.read(userEmailProvider.notifier).state = state.user!.email;
      _ref.read(userPhotoUrlProvider.notifier).state = state.user!.photoUrl;
    }
  }
}
