package com.order.dto.ssafyApi.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class AccountDepositResponseDto {

    @JsonProperty("Header")
    private AccountDepositResponseDto.Header header;

    @JsonProperty("REC")
    private AccountDepositResponseDto.Rec REC;

    @Data
    public static class Header {

        private String responseCode;
        private String responseMessage;
        private String apiName;
        private String transmissionDate;
        private String transmissionTime;
        private String institutionCode;
        private String apiKey;
        private String apiServiceCode;
        private String institutionTransactionUniqueNo;
    }

    @Data
    public static class Rec {
        private String transactionUniqueNo;
        private String transactionDate;
    }
}
