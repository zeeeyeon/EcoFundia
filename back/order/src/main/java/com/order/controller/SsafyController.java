package com.order.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.order.dto.ssafyApi.request.AccountDepositDto;
import com.order.dto.ssafyApi.request.HeaderDto;
import com.order.dto.ssafyApi.response.AccountDepositResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ssafy")
@RequiredArgsConstructor
public class SsafyController {


    private final com.order.service.ssafyApi.ssafyApiService ssafyApiService;
    @Value("${ssafy.apikey}")
    private String apikey;

    //돈충전
    @PostMapping("/account/deposit")
    public AccountDepositResponseDto accountDeposit(
            @RequestParam(name = "userKey") String userKey,
            @RequestParam(name = "accountNo") String accountNo,
            @RequestParam(name = "money") String money
    ){
        // 3. 계좌 이체 하기
        // 3.1 header 만들기
        HeaderDto headerDto = new HeaderDto().buildHeaderDto("updateDemandDepositAccountDeposit", userKey, apikey);

        // 3.2 request 만들기
        AccountDepositDto accountDepositDto = new AccountDepositDto().buildAccountDepositDto(
                headerDto , accountNo, money
        );

        // 요청 보내기
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(accountDepositDto);
            System.out.println("📦 최종 전송 JSON: " + json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }


        AccountDepositResponseDto response = ssafyApiService.accountDeposit(accountDepositDto);
        return response;
    }
}
