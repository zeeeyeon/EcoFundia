package com.order.dto.user.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerFundingDetailOrderUserInfoListResponseDto {
    private int userId;
    private String name;
    private String nickname;
}
