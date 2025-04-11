package com.coupon.common;

import com.coupon.common.dto.ExceptionContent;
import com.coupon.common.exception.CustomException;
import com.coupon.common.response.Response;
import jakarta.persistence.PersistenceException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import static com.coupon.common.response.ResponseCode.BINDING_ERROR;
import static com.coupon.common.response.ResponseCode.DATABASE_ERROR;


@RestControllerAdvice
public class GlobalExceptionHandler {

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

    @ExceptionHandler(PersistenceException.class)
    public ResponseEntity<?> handlePersistenceException(PersistenceException e) {
        return ResponseEntity.ok(Response.create(DATABASE_ERROR, e.getMessage()));
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
