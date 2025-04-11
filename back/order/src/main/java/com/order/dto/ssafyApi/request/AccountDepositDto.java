package com.order.dto.ssafyApi.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AccountDepositDto {

    @JsonProperty("Header")
    private HeaderDto Header;
    private String accountNo;
    private String transactionBalance;
    private String transactionSummary;

    public AccountDepositDto buildAccountDepositDto(HeaderDto header, String accountNo, String transactionBalance) {

        return AccountDepositDto.builder()
                .Header(header)
                .accountNo(accountNo)
                .transactionSummary("{수시입출금} : 입금")
                .transactionBalance(transactionBalance)
                .build();

    }
}
