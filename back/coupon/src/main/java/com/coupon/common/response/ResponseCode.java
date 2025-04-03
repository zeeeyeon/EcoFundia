package com.coupon.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    // 쿠폰

    ISSUED_COUPON(successCode(), HttpStatus.CREATED, "쿠폰이 정상적으로 발급되었습니다."),

    COUPON_EXPIRED(400, HttpStatus.BAD_REQUEST, "만료된 쿠폰입니다."),
    COUPON_NOT_FOUND(404, HttpStatus.NOT_FOUND, "존재하지 않는 쿠폰입니다."),
    COUPON_ALREADY_ISSUED(404, HttpStatus.BAD_REQUEST, "이미 발급받은 쿠폰입니다."),
    COUPON_OUT_OF_STOCK(404, HttpStatus.NOT_FOUND, "준비된 쿠폰 수량이 소진되었습니다."),

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
