package com.ssafy.user.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    // 성공 응답 (200)
    SUCCESS(200, HttpStatus.OK, "Success"),
    GET_WISHLIST(200, HttpStatus.OK, "위시리스트를 성공적으로 조회했습니다."),
    DELETE_WISHLIST(200, HttpStatus.OK, "위시리스트에서 삭제되었습니다."),
    LOGIN_SUCCESS(200, HttpStatus.OK, "로그인에 성공했습니다."),
    REISSUE_SUCCESS(200, HttpStatus.OK, "액세스토큰이 재발급 되었습니다."),
    GET_MYINFO(200, HttpStatus.OK, "내정보를 불러오는데 성공했습니다."),
    UPDATE_MYINFO(200, HttpStatus.OK, "내정보를 수정하는데 성공했습니다."),
    GET_MY_FUNDING_SUCCESS(200, HttpStatus.OK, "내 펀딩 조회 성공"),
    GET_MY_TOTAL_FUNDING_SUCCESS(200, HttpStatus.OK, "내 총 펀딩 금액 조회 성공"),
    GET_MY_REVIEW_SUCCESS(200, HttpStatus.OK, "내 리뷰 조회 성공"),
    UPDATE_MY_REVIEW_SUCCESS(200, HttpStatus.OK, "리뷰 수정 성공"),
    DELETE_MY_REVIEW_SUCCESS(200, HttpStatus.OK, "리뷰 삭제 성공"),
    LOGOUT_SUCCESS(200,HttpStatus.OK, "로그아웃에 성공하였습니다."),


    // 생성 응답 (201)
    CREATE_USER(201, HttpStatus.CREATED, "회원가입에 성공하였습니다."),
    CREATE_WISHLIST(201, HttpStatus.CREATED, "위시리스트에 추가되었습니다."),
    CREATE_MY_REVIEW_SUCCESS(201, HttpStatus.CREATED, "리뷰 작성 성공"),
    CREATE_PAYMENT_SUCCESS(201, HttpStatus.CREATED, "결제 생성 성공"),

    // 클라이언트 오류 (400)
    MISSING_REFRESH_TOKEN(400, HttpStatus.BAD_REQUEST, "Refresh Token이 제공되지 않았습니다."),


    // 인증 오류 (401)
    INVALID_ACCESS_TOKEN(401, HttpStatus.UNAUTHORIZED, "유효하지 않은 액세스 토큰입니다. 갱신 해주세요."),
    INVALID_REFRESH_TOKEN(401, HttpStatus.UNAUTHORIZED, "Refresh Token이 만료되었거나 유효하지 않습니다."),

    // 리소스 없음 (404)
    USER_NOT_SIGNED_UP(404, HttpStatus.NOT_FOUND, "해당 이메일로 가입된 사용자가 없습니다. 회원가입이 필요합니다."),
    USER_NOT_FOUND(404, HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),


    // 기타 예시 - 서버 내부 오류 (500)
    INTERNAL_SERVER_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생하였습니다.");


    private final int code;
    private final HttpStatus httpStatus;
    private final String message;
}
