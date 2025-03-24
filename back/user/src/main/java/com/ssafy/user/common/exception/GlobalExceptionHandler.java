package com.ssafy.user.common.exception;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.user.common.response.Response;
import com.ssafy.user.common.response.ResponseCode;
import feign.FeignException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // CustomException을 처리하는 핸들러
    @ExceptionHandler(CustomException.class)
    public ResponseEntity<?> handleCustomException(CustomException ex) {
        // 예외 메시지와 적절한 ResponseCode를 이용해 Response 객체 생성
        Response response = Response.create(
                // 만약 CustomException 생성 시 ResponseCode를 이용했다면, 해당 코드 대신 ex.getMessage()를 활용할 수도 있습니다.
                ResponseCode.BAD_REQUEST, ex.getMessage()
        );
        return new ResponseEntity<>(response, ex.getHttpStatus());
    }
    // 기타 처리하지 않은 예외에 대한 기본 핸들러 (옵션)
    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handleException(Exception ex) {
        Response response = Response.create(ResponseCode.INTERNAL_SERVER_ERROR, ex.getMessage());
        return new ResponseEntity<>(response, ResponseCode.INTERNAL_SERVER_ERROR.getHttpStatus());
    }

    @ExceptionHandler(FeignException.class)
    public ResponseEntity<?> handleFeignException(FeignException e) {
        String message = extractMessage(e.contentUTF8());

        return ResponseEntity
                .status(e.status())
                .body(Response.error(e.status(), message));
    }

    private String extractMessage(String json) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode node = mapper.readTree(json);
            return node.path("status").path("message").asText();
        } catch (Exception ex) {
            return "외부 요청 실패";
        }
    }
}
