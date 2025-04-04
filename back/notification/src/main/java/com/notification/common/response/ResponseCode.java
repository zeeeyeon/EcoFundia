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
    SEND_FUNDING_END_NOTIFICATION(successCode(), HttpStatus.OK, "해당 펀딩 상품의 마감 알림이 전송되었습니다.");

    private final int code;
    private final HttpStatus httpStatus;
    private final String message;

    private static int successCode() {
        return 200;
    }
}
