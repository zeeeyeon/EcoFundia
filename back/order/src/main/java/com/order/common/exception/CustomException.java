package com.order.common.exception;

import com.order.common.response.ResponseCode;
import com.order.dto.ssafyApi.response.ApiResponseDto;
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
