package com.order.service.ssafyApi;

import com.order.dto.ssafyApi.response.ApiResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ssafyApiController {

    private final WebClient webClient;

    public ApiResponseDto accountTransfer() {
        String url = "https://finapi.p.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountTransfer";

        // Header 객체 구성


    }


    // Header 객체 구성 메서드
    public Map<String, String> commonHeaders() {
        Map<String, String> headerMap = new HashMap<>();

        headerMap.put("apiName",); // 도메인의 마지막 path 명
        headerMap.put("transmissionDate", "20250322"); // 현재 YYYYMMDD
        headerMap.put("transmissionTime", "202600"); // 현재 HHMMSS
        headerMap.put("institutionCode", "00100"); //00100 고정
        headerMap.put("fintechAppNo", "001");   // 001 고정
        headerMap.put("apiServiceCode", ); // 도메인의 마지막 path
        headerMap.put("institutionTransactionUniqueNo", "20250322202930123456"); // YYYYMMDD + HHMMSS + 랜덤 6자리수
        headerMap.put("apiKey", "db2f69fc7f7e49b8a6460ffe136ca608");
        headerMap.put("userKey", "");
    }
}
