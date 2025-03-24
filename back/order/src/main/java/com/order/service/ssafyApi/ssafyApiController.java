package com.order.service.ssafyApi;

import com.order.dto.ssafyApi.response.ApiResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


@Service
@RequiredArgsConstructor
public class ssafyApiController {

    private final WebClient webClient;

    public ApiResponseDto accountTransfer() {
        String url = "https://finapi.p.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountTransfer";

        // Header 객체 구성


    }
}
