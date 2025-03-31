package com.seller.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SellerAccountResponseDto {

    private String sellerAccount;
    private String ssafyUserKey;

    public static SellerAccountResponseDto of(String sellerAccount, String ssafyUserKey) {
        return SellerAccountResponseDto
                .builder()
                .sellerAccount(sellerAccount)
                .ssafyUserKey(ssafyUserKey)
                .build();
    }
}
