package com.seller.common.response;

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
    FORBIDDEN_REVIEW_ACCESS(403, HttpStatus.FORBIDDEN, "해당 리뷰에 대한 수정/삭제 권한이 없습니다."),

    // 판매자 관련
    SELLER_NOT_FOUND(404, HttpStatus.NOT_FOUND, "존재하지 않는 판매자입니다."),


    // 찜 관련
    CREATE_WISHLIST(successCode(), HttpStatus.OK, "위시리스트에 추가되었습니다."),
    GET_WISHLIST(successCode(), HttpStatus.OK, "위시리스트를 성공적으로 조회했습니다."),
    DELETE_WISHLIST(successCode(), HttpStatus.OK, "위시리스트에서 삭제되었습니다."),
    WISHLIST_ALREADY_EXISTS(400, HttpStatus.BAD_REQUEST, "이미 위시리스트에 추가된 상품입니다."),

    // 일반 오류
    BINDING_ERROR(400, HttpStatus.BAD_REQUEST, "입력값 중 검증에 실패한 값이 있습니다."),
    BAD_REQUEST(400, HttpStatus.BAD_REQUEST, "올바르지 않은 요청입니다."),
    DATABASE_ERROR(500, HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),
    BAD_SQL_ERROR(400, HttpStatus.BAD_REQUEST, "SQL 문법 오류가 발생했습니다."),
    DATA_NOT_FOUND(404, HttpStatus.NOT_FOUND, "조회된 데이터가 없습니다."),

    GRANT_SELLER_ROLE(201, HttpStatus.CREATED, "판매자로 변경되었습니다."),
    GET_SELLER_TOTAL_AMOUNT(successCode(), HttpStatus.OK, "판매자의 총 펀딩액이 조회되었습니다."),
    GET_SELLER_TOTAL_FUNDING_COUNT(successCode(), HttpStatus.OK, "판매자의 진행중인 펀딩 상품 개수가 조회되었습니다."),
    GET_SELLER_TODAY_ORDER_COUNT(successCode(), HttpStatus.OK, "판매자의 진행중인 오늘 펀딩 주문 개수가 조회되었습니다."),
    GET_SELLER_ONGOING_TOP_FIVE_FUNDING(successCode(), HttpStatus.OK, "판매자의 진행중인 TOP5 펀딩 상품이 조회되었습니다."),
    GET_SELLER_ONGOING_FUNDING_LIST(successCode(), HttpStatus.OK, "판매자의 진행중인 펀딩 상품 리스트가 조회되었습니다."),
    GET_SELLER_END_FUNDING_LIST(successCode(), HttpStatus.OK, "판매자의 종료된 펀딩 상품 리스트가 조회되었습니다."),
    GET_SELLER_TODAY_ORDER_TOP_THREE_LIST(successCode(), HttpStatus.OK, "판매자의 오늘의 펀딩 모금액 리스트가 조회되었습니다."),
    GET_SELLER_FUNDING_DETAIL(successCode(), HttpStatus.OK, "판매자의 해당 펀당 상품 상세 정보가 조회되었습니다."),
    GET_SELLER_FUNDING_DETAIL_ORDER_LIST(successCode(), HttpStatus.OK, "해당 펀딩 상품에 대한 사용자의 주문 리스트가 조회되었습니다."),
    GET_SELLER_MONTH_AMOUNT_STATISTICS(successCode(), HttpStatus.OK, "판매자의 월별 모금액 통계 현황이 조회되었습니다."),
    GET_SELLER_FUNDING_DETAIL_STATISTICS(successCode(), HttpStatus.OK, "해당 펀딩 상품에 대한 연령대별 통계가 조회되었습니다."),
    GET_SELLER_BRAND_STATISTICS(successCode(), HttpStatus.OK, "해당 판매자 브랜드의 연령별 통계가 조회되었습니다.");

    private final int code;
    private final HttpStatus httpStatus;
    private final String message;

    private static int successCode() {
        return 200;
    }


}
