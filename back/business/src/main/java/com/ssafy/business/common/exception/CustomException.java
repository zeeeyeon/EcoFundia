package com.ssafy.business.common.exception;

import com.ssafy.business.common.response.ResponseCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.apache.commons.lang.exception.NestableRuntimeException;

@Getter
public class CustomException extends NestableRuntimeException {

    private ResponseCode responseCode;
    private Content content;

    public CustomException(ResponseCode responseCode) {
        super(responseCode.getMessage());
        this.responseCode = responseCode;
    }

    public CustomException(ResponseCode responseCode, String field, String message) {
        this(responseCode);
        content = new Content(field, message);
    }

    @Getter
    @AllArgsConstructor
    private static class Content {
        private String field;
        private String message;
    }
}
