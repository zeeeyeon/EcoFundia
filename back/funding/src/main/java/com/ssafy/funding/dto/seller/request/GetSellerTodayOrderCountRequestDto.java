package com.ssafy.funding.dto.seller.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTodayOrderCountRequestDto {
    private List<Integer> fundingIdList;
}
