package com.ssafy.user.common.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
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

    public static <T> Response<?> error(int statusCode, String message) {
        return Response.builder()
                .status(new Status(statusCode, message))
                .content(null)
                .build();
    }
}
