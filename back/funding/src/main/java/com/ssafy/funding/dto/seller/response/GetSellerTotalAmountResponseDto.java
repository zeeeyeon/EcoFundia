package com.ssafy.funding.dto.seller.response;

import lombok.*;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTotalAmountResponseDto {
    int totalAmount;
}
