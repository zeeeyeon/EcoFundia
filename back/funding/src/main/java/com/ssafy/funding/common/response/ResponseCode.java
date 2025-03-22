package com.ssafy.funding.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseCode {

    // 펀딩 관련
    CREATE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 생성되었습니다."),
    GET_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 조회되었습니다."),
    UPDATE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 변경되었습니다."),
    DELETE_FUNDING(successCode(), HttpStatus.OK, "펀딩이 성공적으로 삭제되었습니다."),
    GET_FUNDING_STATUS(successCode(), HttpStatus.OK, "펀딩상태가 성공적으로 조회되었습니다."),

    FUNDING_NOT_FOUND(404, HttpStatus.NOT_FOUND, "해당 ID의 펀딩이 존재하지 않습니다"),

    // 파일 관련
    FAIL_FILE_UPLOAD(500, HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류로 인해 파일 업로드가 실패하였습니다."),
    FAIL_FILE_DELETE(500, HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류로 인해 파일 삭제가 실패하였습니다."),

    // 리뷰 관련
    CREATE_REVIEW(successCode(), HttpStatus.OK, "리뷰가 성공적으로 등록되었습니다."),
    GET_REVIEW(successCode(), HttpStatus.OK, "리뷰가 성공적으로 조회되었습니다."),
    GET_REVIEW_LIST(successCode(), HttpStatus.OK, "해당 펀딩의 리뷰 리스트가 성공적으로 조회되었습니다."),
    UPDATE_REVIEW(successCode(), HttpStatus.OK, "리뷰가 성공적으로 수정되었습니다."),
    DELETE_REVIEW(successCode(), HttpStatus.OK, "리뷰가 성공적으로 삭제되었습니다."),

    REVIEW_NOT_FOUND(404, HttpStatus.NOT_FOUND, "해당 ID의 리뷰가 존재하지 않습니다."),
    REVIEW_NOT_ALLOWED(403, HttpStatus.FORBIDDEN, "해당 펀딩 상태에서는 리뷰를 작성할 수 없습니다."),
    REVIEW_ALREADY_EXISTS(400, HttpStatus.BAD_REQUEST, "해당 유저는 이미 이 펀딩에 리뷰를 작성했습니다."),

    // 일반 오류
    BINDING_ERROR(400, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    DATABASE_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),
    BAD_SQL_ERROR(400, HttpStatus.BAD_REQUEST, "SQL 문법 오류가 발생했습니다."),
    DATA_NOT_FOUND(404, HttpStatus.NOT_FOUND, "조회된 데이터가 없습니다.");

    private final int code;
    private final HttpStatus httpStatus;
    private final String message;

    private static int successCode() {
        return 200;
    }
}
