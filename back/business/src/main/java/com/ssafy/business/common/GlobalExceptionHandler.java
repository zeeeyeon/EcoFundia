package com.ssafy.business.common;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.business.common.dto.ExceptionContent;
import com.ssafy.business.common.exception.CustomException;

import com.ssafy.business.common.response.Response;
import feign.FeignException;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;


import static com.ssafy.business.common.response.ResponseCode.*;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(FeignException.class)
    public ResponseEntity<?> handleFeignException(FeignException e) {
        String message = extractMessage(e.contentUTF8());

        return ResponseEntity
                .status(e.status())
                .body(Response.fail(e.status(), message));
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

    @ExceptionHandler(value = CustomException.class)
    protected ResponseEntity<?> handleCustomException(CustomException exception) {
//        return ResponseEntity.ok(
//                Response.create(exception.getResponseCode(), exception.getContent())
//        );

        return new ResponseEntity<>(
                Response.create(exception.getResponseCode(), exception.getContent()),
                exception.getResponseCode().getHttpStatus()
        );
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public ResponseEntity<?> bindingException(BindException e) {
        BindingResult bindingResult = e.getBindingResult();
        String field = getFieldName(bindingResult);
        String message = getDefaultMessage(bindingResult);

        ExceptionContent content = new ExceptionContent(field, message);
        return ResponseEntity.ok(Response.create(BINDING_ERROR, content));
    }

    private String getDefaultMessage(BindingResult bindingResult) {
        String defaultMessage = "";
        try {
            defaultMessage = bindingResult.getFieldError().getDefaultMessage();
        } catch (NullPointerException e) {
        }
        return defaultMessage;
    }

    private String getFieldName(BindingResult bindingResult) {
        String fieldName = "";
        try {
            fieldName = bindingResult.getFieldError().getField();
        } catch (NullPointerException e) {
        }
        return fieldName;
    }
}
