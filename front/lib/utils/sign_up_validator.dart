import 'package:front/features/auth/domain/entities/sign_up_entity.dart';
import 'package:front/core/exceptions/auth_exception.dart';

/// 회원가입 전용 유효성 검증 클래스
/// UI 표시용 메시지와 비즈니스 로직 검증을 통합 관리
class SignUpValidator {
  /// UI 입력 검증 - 닉네임 (UI 표시용)
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    // 정규식: 2글자 이상 10글자 이하, 알파벳, 숫자, 한글만 허용
    final regex = RegExp(r'^[A-Za-z0-9가-힣]{2,10}$');
    if (!regex.hasMatch(value)) {
      return '닉네임은 2~10글자, 한글, 영어, 숫자만 가능합니다.';
    }
    return null;
  }

  /// UI 입력 검증 - 나이 (UI 표시용)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return '나이를 입력해주세요.';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return '숫자만 입력 가능합니다.';
    }

    if (age < 14 || age > 120) {
      return '14세 이상 120세 이하의 나이를 입력해주세요.';
    }
    return null;
  }

  /// UI 입력 검증 - 성별 (UI 표시용)
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return '성별을 선택해주세요.';
    }
    if (value != '남성' && value != '여성') {
      return '올바른 성별을 선택해주세요.';
    }
    return null;
  }

  /// 비즈니스 로직 검증 - 회원가입 데이터 (예외 발생)
  static void validateSignUpData(SignUpEntity entity) {
    // 이메일 검증
    if (entity.email.isEmpty) {
      throw ValidationException('이메일은 필수 입력 항목입니다.');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(entity.email)) {
      throw ValidationException('유효한 이메일 주소를 입력해주세요.');
    }

    // 닉네임 검증
    if (entity.nickname.length < 2 || entity.nickname.length > 10) {
      throw ValidationException('닉네임은 2~10자 사이여야 합니다.');
    }

    // 성별 검증
    final String genderLower = entity.gender.toLowerCase();
    if (!['male', 'female'].contains(genderLower)) {
      throw ValidationException('성별은 male 또는 female이어야 합니다.');
    }

    // 나이 검증
    if (entity.age < 14 || entity.age > 120) {
      throw ValidationException('나이는 14세 이상 120세 이하여야 합니다.');
    }

    // 토큰 검증
    if (entity.token == null || entity.token!.isEmpty) {
      throw ValidationException('인증 코드가 필요합니다.');
    }
  }

  /// 회원가입 입력값 검증 - ViewModel에서 사용
  static void validateSignUpInput({
    required String email,
    required String nickname,
    required String gender,
    required String age,
    required String? token,
  }) {
    if (email.isEmpty) {
      throw ValidationException('이메일을 입력해주세요.');
    }

    if (nickname.isEmpty) {
      throw ValidationException('닉네임을 입력해주세요.');
    }

    if (gender.isEmpty) {
      throw ValidationException('성별을 선택해주세요.');
    }

    final int? parsedAge = int.tryParse(age);
    if (parsedAge == null) {
      throw ValidationException('올바른 나이를 입력해주세요.');
    }

    if (token == null || token.isEmpty) {
      throw ValidationException('인증 코드가 필요합니다.');
    }
  }

  /// UI에 표시할 성별 값을 서버 형식(MALE/FEMALE)으로 변환
  static String mapGenderToServer(String uiGender) {
    return uiGender == '남성' ? 'MALE' : 'FEMALE';
  }
}
