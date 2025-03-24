package com.order.dto.ssafyApi.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransferRequestDto {

    private HeaderDto header;
    private String depositAccountNo;
    private String depositTransactionSummary;
    private String transactionBalance;
    private String withdrawalAccountNo;
    private String withdrawalTransactionSummary;

    public TransferRequestDto buildTransferRequestDto(HeaderDto header, String sellerAccount, String userAccount, String price) {

        return TransferRequestDto.builder()
                .header(header)
                .depositAccountNo(sellerAccount)
                .depositTransactionSummary("{수시입출금} : 입금(이체)")
                .transactionBalance(price)
                .withdrawalAccountNo(userAccount)
                .withdrawalTransactionSummary("{수시입출금} : 출금(이체)")
                .build();
    }
}
