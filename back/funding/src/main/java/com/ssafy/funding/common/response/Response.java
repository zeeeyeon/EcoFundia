package com.ssafy.funding.common.response;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder(access = AccessLevel.PRIVATE)
public class Response<T> {
    private Status status;
    private T content;

    @Getter
    @AllArgsConstructor
    private static class Status {
        private int code;
        private String message;
    }

    public static <T> Response<?> create(ResponseCode responseCode, T content) {
        return Response.builder()
                .status(new Status(responseCode.getCode(), responseCode.getMessage()))
                .content(content)
                .build();
    }
}
