package com.coupon.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    // 쿠폰
    ISSUED_COUPON(successCode(), HttpStatus.CREATED, "쿠폰이 정상적으로 발급되었습니다."),
    GET_COUNT_COUPON(successCode(), HttpStatus.OK, "보유한 쿠폰 수량을 조회했습니다."),
    GET_COUPONS(successCode(), HttpStatus.OK, "보유한 쿠폰 목록을 조회했습니다."),

    COUPON_EXPIRED(410, HttpStatus.GONE, "쿠폰의 유효기간이 만료되었습니다."),
    COUPON_NOT_FOUND(404, HttpStatus.NOT_FOUND, "해당 쿠폰이 존재하지 않습니다."),
    COUPON_ALREADY_ISSUED(409, HttpStatus.CONFLICT, "이미 발급받은 쿠폰입니다."),
    COUPON_OUT_OF_STOCK(410, HttpStatus.GONE, "준비된 쿠폰 수량이 모두 소진되었습니다."),
    COUPON_NOT_YET_TIME(404, HttpStatus.FORBIDDEN, "쿠폰은 오전 10시부터 발급 가능합니다."),

    // 일반 오류
    BINDING_ERROR(400, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    DATABASE_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),
    BAD_SQL_ERROR(400, HttpStatus.BAD_REQUEST, "SQL 문법 오류가 발생했습니다."),
    DATA_NOT_FOUND(404, HttpStatus.NOT_FOUND, "조회된 데이터가 없습니다.");

    private final int code;
    private final HttpStatus httpStatus;
    private final String message;

    private static int successCode() {
        return 200;
    }
}
