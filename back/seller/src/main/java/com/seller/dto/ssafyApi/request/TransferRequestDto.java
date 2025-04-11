package com.seller.dto.ssafyApi.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransferRequestDto {

    @JsonProperty("Header")
    private HeaderDto Header;
    private String depositAccountNo;
    private String depositTransactionSummary;
    private int transactionBalance;
    private String withdrawalAccountNo;
    private String withdrawalTransactionSummary;

    public TransferRequestDto buildTransferRequestDto(HeaderDto header, String adminAccount, String userAccount, int price) {

        return TransferRequestDto.builder()
                .Header(header)
                .depositAccountNo(userAccount)
                .depositTransactionSummary("{수시입출금} : 입금(이체)")
                .transactionBalance(price)
                .withdrawalAccountNo(adminAccount)
                .withdrawalTransactionSummary("{수시입출금} : 출금(이체)")
                .build();
    }
}
