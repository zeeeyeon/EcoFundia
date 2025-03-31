package com.ssafy.business.decoder;

import feign.Response;
import feign.codec.ErrorDecoder;
import jakarta.ws.rs.BadRequestException;
import jakarta.ws.rs.NotFoundException;
import org.springframework.http.HttpStatus;

import java.rmi.ServerException;

public class CustomErrorDecoder implements ErrorDecoder {

    private final ErrorDecoder defaultDecoder = new Default();

    @Override
    public Exception decode(String methodKey, Response response) {
        HttpStatus status = HttpStatus.valueOf(response.status());

        switch (status) {
            case NOT_FOUND:
                return new NotFoundException("리소스를 찾을 수 없습니다: " + methodKey);
            case BAD_REQUEST:
                return new BadRequestException("잘못된 요청입니다: " + methodKey);
            case INTERNAL_SERVER_ERROR:
                return new ServerException("서버 내부 오류가 발생했습니다: " + methodKey);
            default:
                return defaultDecoder.decode(methodKey, response);  // 기본 예외 처리
        }
    }
}
