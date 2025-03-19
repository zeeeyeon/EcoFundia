package com.ssafy.business.common;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ResponseType {

    SUCCESS(HttpStatus.OK, "SU", "Success"),
    NOT_FOUND(HttpStatus.BAD_REQUEST, "NF", "Not Found"),
    FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "FA", "서버에서 오류가 발생했습니다."),
    INVALID_ACCESS_TOKEN(HttpStatus.UNAUTHORIZED, "IAT", "Invalid access token."),
    INVALID_REFRESH_TOKEN(HttpStatus.UNAUTHORIZED, "IRT", "Invalid refresh token."),
    NOT_EXPIRED_TOKEN_YET(HttpStatus.BAD_REQUEST, "NETY", "Not expired token yet."),
    EXISTED_USER_EMAIL(HttpStatus.BAD_REQUEST, "EUE", "Existed User Email"),
    NO_EXISTED_USER_EMAIL(HttpStatus.OK, "NEUE", "No Existed User Email"),
    EXISTED_USER_NICKNAME(HttpStatus.BAD_REQUEST, "EUN", "Existed User Nickname"),
    NO_EXISTED_USER_NICKNAME(HttpStatus.OK, "NEUN", "No Existed User Nickname"),
    EXISTED_USER_PHONE(HttpStatus.OK, "EUP", "Existed User Phone"),
    NO_MATCHING_CLIMBING_GYM(HttpStatus.NO_CONTENT, "NMCG", "No matching climbing gym found."),
    NOT_FOUND_404(HttpStatus.NOT_FOUND, "NF", "Not Found"),
    CREATED(HttpStatus.CREATED, "CR", "Row Created successfully"),
    CREATION_FAILED_BAD_REQUEST(HttpStatus.BAD_REQUEST, "CFBR", "Bad request, invalid data provided for creation."),
    DATA_ALREADY_EXISTS(HttpStatus.CONFLICT, "DAE", "Data already exists."),
    NOT_EXIST_DATE(HttpStatus.NOT_FOUND, "NOT_EXIST_DATE", "해당 날짜의 값이 존재하지 않습니다");

    private final HttpStatus httpStatus; // HTTP 상태 코드
    private final String code;           // 비즈니스 로직에서 사용할 고유 코드
    private final String message;        // 클라이언트에게 전달할 메시지

}
