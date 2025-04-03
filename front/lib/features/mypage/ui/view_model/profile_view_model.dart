import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/services/api_service.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/utils/logger_util.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/services/profile_service.dart';

// 서비스 & 리포지토리 프로바이더 설정
final profileServiceProvider = Provider(
  (ref) => ProfileService(ref.read(apiServiceProvider)),
);
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
      // 인증 상태 확인
      final isAuthenticated = await StorageService.isAuthenticated();

      // 인증되지 않은 경우 API 호출 중단
      if (!isAuthenticated) {
        LoggerUtil.w('⚠️ 프로필 데이터 로드 취소: 인증되지 않음');
        state = AsyncValue.error(
          Exception('인증되지 않은 사용자입니다.'),
          StackTrace.current,
        );
        return;
      }

      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      LoggerUtil.e('❌ 프로필 데이터 로드 실패', e);
      state = AsyncValue.error(e, st);
    }
  }

  /// 닉네임과 계좌를 함께 수정
  Future<void> updateProfile({
    required String nickname,
    required String account,
  }) async {
    try {
      // 인증 상태 확인
      final isAuthenticated = await StorageService.isAuthenticated();

      // 인증되지 않은 경우 API 호출 중단
      if (!isAuthenticated) {
        LoggerUtil.w('⚠️ 프로필 업데이트 취소: 인증되지 않음');
        state = AsyncValue.error(
          Exception('인증되지 않은 사용자입니다.'),
          StackTrace.current,
        );
        return;
      }

      await _repository.updateProfile(nickname: nickname, account: account);

      // 상태 업데이트 (View 반영)
      state = state.whenData((profile) => profile.copyWith(
            nickname: nickname,
            account: account,
          ));
    } catch (e, st) {
      LoggerUtil.e('❌ 프로필 업데이트 실패', e);
      state = AsyncValue.error(e, st);
    }
  }
}
