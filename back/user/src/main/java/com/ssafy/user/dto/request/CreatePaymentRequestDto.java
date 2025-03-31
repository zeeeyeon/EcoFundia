package com.ssafy.user.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreatePaymentRequestDto {
    private int fundingId;
    private int amount;
    private int totalPrice;
}
