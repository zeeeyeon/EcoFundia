package com.seller.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderInfoResponseDto {
    private int fundingId;
    private int totalAmount;
}
