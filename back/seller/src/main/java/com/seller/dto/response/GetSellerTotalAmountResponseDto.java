package com.seller.dto.response;

import lombok.*;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTotalAmountResponseDto {
    int totalAmount;
}
