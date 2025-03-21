package com.ssafy.user.common.exception;

import com.ssafy.user.common.response.ResponseCode;
import org.springframework.http.HttpStatus;

public class CustomException extends RuntimeException {
    private final HttpStatus httpStatus;

    // 메시지와 HttpStatus를 직접 입력하는 생성자
    public CustomException(String message, HttpStatus httpStatus) {
        super(message);
        this.httpStatus = httpStatus;
    }

    // ResponseCode를 받아 생성하는 생성자
    public CustomException(ResponseCode responseCode) {
        super(responseCode.getMessage());
        this.httpStatus = responseCode.getHttpStatus();
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }
}
