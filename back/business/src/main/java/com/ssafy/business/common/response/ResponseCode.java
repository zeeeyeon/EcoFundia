package com.ssafy.business.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {
    SUCCESS_LOGIN(successCode(), HttpStatus.OK, "로그인이 성공적으로 완료되었습니다."),
    SUCCESS_SIGNUP(successCode(), HttpStatus.OK, "회원가입이 성공적으로 완료되었습니다."),

    BINDING_ERROR(400, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),

    GET_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 조회되었습니다."),
    GET_TOTAL_FUNDING(successCode(), HttpStatus.OK, "현재까지 펀딩 금액이 성공적으로 조회되었습니다."),
    GET_FUNDING_DETAIL(successCode(), HttpStatus.OK, "해당 펀딩 상세 정보가 성공적으로 조회되었습니다.");

    private int code;
    private HttpStatus httpStatus;
    private String message;

    private static int successCode() {
        return 200;
    }
}
