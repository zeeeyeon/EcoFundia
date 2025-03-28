package com.order.dto.funding.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerTodayOrderCountRequestDto {
    private List<Integer> fundingIdList;
}
