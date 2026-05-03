import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userNameProvider = StateProvider<String>((ref) => 'Usuario');
final userEmailProvider = StateProvider<String>((ref) => 'usuario@bibu.app');
final userPhotoUrlProvider = StateProvider<String?>((ref) => null);

final profileEditProvider = StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(ref);
});

class ProfileEditState {
  final String name;
  final String email;
  final String? photoUrl;
  final String? signInMethod;
  final bool isLoading;
  ProfileEditState({
    required this.name,
    required this.email,
    this.photoUrl,
    this.signInMethod,
    this.isLoading = false,
  });
  bool get isGoogleUser => signInMethod == 'google.com';
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final Ref _ref;
  ProfileEditNotifier(this._ref) : super(ProfileEditState(name: 'Usuario', email: 'usuario@bibu.app'));

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();

    final signInMethod = prefs.getString('auth_sign_in_method');

    final photoUrl = prefs.getString('user_photo_url') ??
        _ref.read(userPhotoUrlProvider);

    state = state.copyWith(
      name: prefs.getString('user_name') ?? 'Usuario',
      email: prefs.getString('user_email') ?? 'usuario@bibu.app',
      photoUrl: photoUrl,
      signInMethod: signInMethod,
      isLoading: false,
    );
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();

    if (!state.isGoogleUser) {
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      _ref.read(userNameProvider.notifier).state = name;
      _ref.read(userEmailProvider.notifier).state = email;
    }

    if (photoUrl != null) {
      await prefs.setString('user_photo_url', photoUrl);
    }
    _ref.read(userPhotoUrlProvider.notifier).state = photoUrl;

    state = state.copyWith(isLoading: false);
  }

  Future<void> savePhotoOnly(String? photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (photoUrl != null) {
      await prefs.setString('user_photo_url', photoUrl);
    }
    _ref.read(userPhotoUrlProvider.notifier).state = photoUrl;
    state = state.copyWith(photoUrl: photoUrl);
  }
}

extension ProfileEditStateCopyWith on ProfileEditState {
  ProfileEditState copyWith({String? name, String? email, String? photoUrl, String? signInMethod, bool? isLoading}) {
    return ProfileEditState(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      signInMethod: signInMethod ?? this.signInMethod,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}