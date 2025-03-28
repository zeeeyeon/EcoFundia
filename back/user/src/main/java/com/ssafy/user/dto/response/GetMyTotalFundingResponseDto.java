package com.ssafy.user.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetMyTotalFundingResponseDto {
    private int total;
}
