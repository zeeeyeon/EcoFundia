package com.seller.dto.response;


import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetCompletedFundingsResponseDto {
    private String title;
    private LocalDateTime endDate;
    private int totalOrderCount;
    private int totalAmount;
    private int progressPercentage;
}
