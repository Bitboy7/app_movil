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
  final bool isLoading;
  ProfileEditState({required this.name, required this.email, this.photoUrl, this.isLoading = false});
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final Ref _ref;
  ProfileEditNotifier(this._ref) : super(ProfileEditState(name: 'Usuario', email: 'usuario@bibu.app'));

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      name: prefs.getString('user_name') ?? 'Usuario',
      email: prefs.getString('user_email') ?? 'usuario@bibu.app',
      photoUrl: prefs.getString('user_photo_url'),
      isLoading: false,
    );
  }

  Future<void> saveProfile(String name, String email, String? photoUrl) async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (photoUrl != null) {
      await prefs.setString('user_photo_url', photoUrl);
    }
    _ref.read(userNameProvider.notifier).state = name;
    _ref.read(userEmailProvider.notifier).state = email;
    _ref.read(userPhotoUrlProvider.notifier).state = photoUrl;
    state = state.copyWith(name: name, email: email, photoUrl: photoUrl, isLoading: false);
  }
}

extension ProfileEditStateCopyWith on ProfileEditState {
  ProfileEditState copyWith({String? name, String? email, String? photoUrl, bool? isLoading}) {
    return ProfileEditState(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}