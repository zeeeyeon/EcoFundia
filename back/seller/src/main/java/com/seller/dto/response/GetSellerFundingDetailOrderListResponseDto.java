package com.seller.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerFundingDetailOrderListResponseDto {
    private int orderId;
    private String nickname;
    private LocalDateTime createdAt;
    private int totalPrice;
    private int quantity;
}
