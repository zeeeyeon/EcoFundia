package com.ssafy.business.util;


import com.ssafy.business.common.ApiResponse;
import com.ssafy.business.common.ResponseType;
import org.springframework.http.ResponseEntity;

public class ApiResponseUtil {
    public static <T> ResponseEntity<ApiResponse<T>> success(ResponseType responseType, T content) {
        return ResponseEntity.status(responseType.getHttpStatus())
                .body(ApiResponse.of(responseType, content));
    }

    public static ResponseEntity<ApiResponse<Void>> success(ResponseType responseType) {
        return ResponseEntity.status(responseType.getHttpStatus())
                .body(ApiResponse.of(responseType));
    }

    public static ResponseEntity<ApiResponse<Void>> error(ResponseType responseType) {
        return ResponseEntity.status(responseType.getHttpStatus())
                .body(ApiResponse.of(responseType));
    }

}
