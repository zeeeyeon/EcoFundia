import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/services/profile_service.dart';

// 서비스 & 리포지토리 프로바이더 설정
final profileServiceProvider = Provider((ref) => ProfileService());
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.read(profileServiceProvider)),
);

// 사용자 프로필 상태 관리
final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel>>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileNotifier(repository)..fetchProfile();
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncLoading());

  Future<void> fetchProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 닉네임 수정
  void updateNickname(String newNickname) {
    state = state.whenData((profile) => ProfileModel(
          userId: profile.userId,
          email: profile.email,
          name: profile.name,
          nickname: newNickname,
          gender: profile.gender,
          age: profile.age,
          createdAt: profile.createdAt,
        ));
  }
}
