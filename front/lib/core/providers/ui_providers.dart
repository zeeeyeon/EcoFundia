import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 필요 모달 표시 상태 Provider
final isLoginModalShowingProvider = StateProvider<bool>((ref) => false);
