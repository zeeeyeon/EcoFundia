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
    GET_FUNDING_DETAIL(successCode(), HttpStatus.OK, "해당 펀딩 상세 정보가 성공적으로 조회되었습니다."),
    GET_FUNDING_REVIEW(successCode(), HttpStatus.OK, "리뷰를 성공적으로 조회되었습니다."),
    GET_SELLER_DETAIL(successCode(), HttpStatus.OK, "판매자 상세 정보를 성공적으로 조회되었습니다."),
    GET_SELLER_FUNDING(successCode(), HttpStatus.OK, "판매자의 펀딩 프로젝트 정보를 성공적으로 조회되었습니다."),

    // 일반 오류
    DATABASE_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),
    BAD_SQL_ERROR(400, HttpStatus.BAD_REQUEST, "SQL 문법 오류가 발생했습니다."),
    DATA_NOT_FOUND(404, HttpStatus.NOT_FOUND, "조회된 데이터가 없습니다."),

    TOPIC_BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "토픽값이 올바르지 않습니다"),
    SORT_BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "정렬값이 올바르지 않습니다"),
    CATEGORIES_BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "카테고리가 올바르지 않습니다"),
    CURRENT_NOT_FUNDING(204, HttpStatus.NO_CONTENT, "현재 진행중인 펀딩이 없습니다.."),
    FUNDING_NOT_FOUND(204, HttpStatus.OK, "조회된 편딩이 없습니다.."),


    REVIEW_NOT_FOUND(204,HttpStatus.NO_CONTENT, "조회된 리뷰가 없습니다.."),
    SELLER_NOT_FOUND(404, HttpStatus.NOT_FOUND, "해당 ID의 셀러가 존재하지 않습니다");

    private int code;
    private HttpStatus httpStatus;
    private String message;

    private static int successCode() {
        return 200;
    }
}
