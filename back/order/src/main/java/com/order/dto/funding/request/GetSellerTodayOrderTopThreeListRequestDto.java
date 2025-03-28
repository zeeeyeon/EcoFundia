package com.order.dto.funding.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTodayOrderTopThreeListRequestDto {
    private List<Integer> fundingIdList;
}
