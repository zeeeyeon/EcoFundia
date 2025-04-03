package com.order.dto.seller.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TotalAmountResponseDto {
    private int fundingId;
    private int totalAmount;
}
