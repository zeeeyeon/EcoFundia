package com.ssafy.funding.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    CREATE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 생성되었습니다."),
    GET_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 조회되었습니다."),
    UPDATE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 변경되었습니다."),
    DELETE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 삭제되었습니다."),

    FUNDING_NOT_FOUND(404, HttpStatus.NOT_FOUND, "해당 ID의 펀딩이 존재하지 않습니다"),
    FAIL_FILE_UPLOAD(404, HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류로 인해 파일 업로드가 실패하였습니다."),

    BINDING_ERROR(400, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    DATABASE_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),
    BAD_SQL_ERROR(400, HttpStatus.BAD_REQUEST, "SQL 문법 오류가 발생했습니다."),
    DATA_NOT_FOUND(404, HttpStatus.NOT_FOUND, "조회된 데이터가 없습니다.");

    private int code;
    private HttpStatus httpStatus;
    private String message;

    private static int successCode() {
        return 200;
    }
}
