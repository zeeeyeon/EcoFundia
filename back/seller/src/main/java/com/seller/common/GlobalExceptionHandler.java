package com.seller.common;

import com.seller.common.dto.ExceptionContent;
import com.seller.common.exception.CustomException;
import com.seller.common.response.Response;
import org.apache.ibatis.exceptions.PersistenceException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import static com.seller.common.response.ResponseCode.*;


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

    @ExceptionHandler(BadSqlGrammarException.class)
    public ResponseEntity<?> handleBadSqlGrammarException(BadSqlGrammarException e) {
        return ResponseEntity.ok(Response.create(BAD_SQL_ERROR, "SQL 문법 오류가 발생했습니다."));
    }

    @ExceptionHandler(EmptyResultDataAccessException.class)
    public ResponseEntity<?> handleEmptyResultException(EmptyResultDataAccessException e) {
        return ResponseEntity.ok(Response.create(DATA_NOT_FOUND, "조회된 데이터가 없습니다."));
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
