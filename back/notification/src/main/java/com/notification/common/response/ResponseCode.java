package com.notification.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {
    SEND_TO_ALL_TOTAL_ORDER_AMOUNT(successCode(), HttpStatus.OK, "총 주문금액이 조회되었습니다."),
    SEND_PAYMENT_SUCCESS_NOTIFICATION(successCode(), HttpStatus.OK, "해당 펀딩 상품의 결제 성공 알림이 전송되었습니다."),
    SEND_PAYMENT_FAIL_NOTIFICATION(successCode(), HttpStatus.OK, "해당 펀딩 상품의 결제 실패 알림이 전송되었습니다."),
    SEND_FUNDING_END_NOTIFICATION(successCode(), HttpStatus.OK, "해당 펀딩 상품의 마감 알림이 전송되었습니다."),

    GET_CHATROOM_LIST(successCode(), HttpStatus.OK, "유저의 채팅방 리스트를 성공적으로 조회하였습니다."),

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
