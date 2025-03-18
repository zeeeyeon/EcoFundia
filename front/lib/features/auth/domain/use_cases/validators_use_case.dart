class InputValidators {
  /// 닉네임: 2~10글자, 한글/영어/숫자만 허용 (공백 불가)
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

  /// 나이: 2자리 숫자만, 19부터 99까지 허용 (숫자만 입력)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return '나이를 입력해주세요.';
    }
    if (value.length != 2) {
      return '2자리 숫자로 입력해주세요.';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return '숫자만 입력 가능합니다.';
    }
    if (age < 19 || age > 99) {
      return '나이는 19세부터 99세까지 입력 가능합니다.';
    }
    return null;
  }

  /// 성별: null이 아닌 '남성' 또는 '여성'만 허용
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return '성별을 선택해주세요.';
    }
    if (value != '남성' && value != '여성') {
      return '올바른 성별을 선택해주세요.';
    }
    return null;
  }
}
