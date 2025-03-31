package com.ssafy.user.common.exception;

import com.ssafy.user.common.response.ResponseCode;
import org.springframework.http.HttpStatus;

public class CustomException extends RuntimeException {
    private final ResponseCode code;


    // ResponseCode를 받아 생성하는 생성자
    public CustomException(ResponseCode code) {
        super(code.getMessage());
        this.code = code;
    }

    public ResponseCode getResponseCode() {
        return code;
    }
}
