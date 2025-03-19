package com.ssafy.business.common;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public class ApiResponse<T> {

    private final String code;
    private final String message;
    private final T content;

    public static <T> ApiResponse<T> of(ResponseType responseType, T content) {
        return new ApiResponse<>(responseType.getCode(), responseType.getMessage(), content);
    }

    public static ApiResponse<Void> of(ResponseType responseType) {
        return new ApiResponse<>(responseType.getCode(), responseType.getMessage(), null);
    }
}
