package com.order.dto.ssafyApi.response;

import lombok.Data;

import java.util.List;

@Data
public class ApiResponseDto {

    private Header header;
    private List<Rec> REC;

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
        private String accountNo;
        private String transactionDate;
        private String transactionType;
        private String transactionTypeName;
        private String transactionAccountNo;
    }




}
