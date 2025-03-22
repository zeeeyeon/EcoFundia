package com.ssafy.user.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    // 성공 응답 (200)
    SUCCESS("SU", HttpStatus.OK, "Success"),
    LOGOUT_SUCCESS("SU", HttpStatus.OK, "로그아웃 성공"),

    // 생성 응답 (201)
    CREATED("CR", HttpStatus.CREATED, "Row Created successfully"),

    // 클라이언트 오류 (400)
    BAD_REQUEST("BR", HttpStatus.BAD_REQUEST, "잘못된 요청입니다."),
    MISSING_REFRESH_TOKEN("BR", HttpStatus.BAD_REQUEST, "Refresh Token이 제공되지 않았습니다."),
    INVALID_AUTH_HEADER("BR", HttpStatus.BAD_REQUEST, "잘못된 Authorization 헤더 형식입니다."),

    // 인증 오류 (401)
    INVALID_ACCESS_TOKEN("IAT", HttpStatus.UNAUTHORIZED, "유효하지 않은 액세스 토큰입니다. 갱신 해주세요."),
    INVALID_REFRESH_TOKEN("IRT", HttpStatus.UNAUTHORIZED, "Refresh Token이 만료되었거나 유효하지 않습니다."),

    // 리소스 없음 (404)
    USER_NOT_SIGNED_UP("NF", HttpStatus.NOT_FOUND, "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다."),
    USER_NOT_FOUND("NF", HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),


    // 기타 예시 - 서버 내부 오류 (500)
    INTERNAL_SERVER_ERROR("ISE", HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생하였습니다.");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;
}
