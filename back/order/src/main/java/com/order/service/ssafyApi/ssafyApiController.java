package com.order.service.ssafyApi;

import com.order.dto.ssafyApi.request.TransferRequestDto;
import com.order.dto.ssafyApi.response.ApiResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


@Service
@RequiredArgsConstructor
public class ssafyApiController {

    private final WebClient webClient;

    public ApiResponseDto accountTransfer(TransferRequestDto transferRequestDto) {
        String url = "https://finapi.p.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountTransfer";

        return webClient.post()
                .uri(url)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .bodyValue(transferRequestDto)
                .retrieve()
                .bodyToMono(ApiResponseDto.class)
                .block();


    }
}
