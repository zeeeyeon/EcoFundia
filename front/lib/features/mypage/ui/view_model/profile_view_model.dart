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
final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return await repository.getProfile();
});
