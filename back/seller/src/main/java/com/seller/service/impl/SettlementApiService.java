package com.seller.service.impl;

import com.seller.dto.ssafyApi.request.HeaderDto;
import com.seller.dto.ssafyApi.request.TransferRequestDto;
import com.seller.dto.ssafyApi.response.ApiResponseDto;
import com.seller.entity.Seller;
import com.seller.mapper.SellerMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Settlement API 서비스
 * - 중앙 관리자 계좌에서 판매자 계좌로 정산 이체를 수행하기 위한 API 호출 로직
 */
@Service
@RequiredArgsConstructor
public class SettlementApiService {

    private final WebClient webClient;
    private final SellerMapper sellerMapper; // Seller 정보를 DB에서 조회하기 위한 Mapper

    // 중앙 관리자 계좌 번호 (application.yml에서 설정)
    @Value("${adm.account}")
    private String adminAccount;

    // SSAFY API 키 (application.yml에서 설정)
    @Value("${ssafy.apikey}")
    private String apiKey;

    // 사용자 키는 YAML에서 adm.ssafy-user-key로 주입받습니다.
    @Value("${adm.ssafy-user-key}")
    private String userKey;

    /**
     * 정산 이체 요청 DTO를 빌드합니다.
     * - 정산 시 중앙 관리자 계좌(출금)에서 판매자 계좌(입금)로 이체합니다.
     */
    public TransferRequestDto buildSettlementTransferRequest(int amount, int sellerId) {
        // Header 생성
        HeaderDto headerDto = new HeaderDto().buildHeaderDto("updateDemandDepositAccountTransfer", userKey, apiKey);
        // SellerMapper를 통해 판매자 계좌 조회
        Seller seller = sellerMapper.getSeller(sellerId);
        String sellerAccount = seller != null ? seller.getAccount() : null;
        return TransferRequestDto.builder()
                .Header(headerDto)
                // 입금 계좌: 판매자 계좌 (DB에서 조회)
                .depositAccountNo(sellerAccount)
                .depositTransactionSummary("{수시입출금} : 입금(정산)")
                .transactionBalance(amount)
                // 출금 계좌: 중앙 관리자 계좌
                .withdrawalAccountNo(adminAccount)
                .withdrawalTransactionSummary("{수시입출금} : 출금(정산)")
                .build();
    }

    /**
     * 중앙 관리자 계좌에서 판매자 계좌로 정산 이체를 수행합니다.
     */
    public ApiResponseDto transferSettlement(int amount, int sellerId) {
        TransferRequestDto request = buildSettlementTransferRequest(amount, sellerId);
        String url = "https://finopenapi.ssafy.io/ssafy/api/v1/edu/demandDeposit/updateDemandDepositAccountTransfer";

        ApiResponseDto response = webClient.post()
                .uri(url)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ApiResponseDto.class)
                .block();

        System.out.println("Settlement API response: " + response);
        return response;
    }
}
