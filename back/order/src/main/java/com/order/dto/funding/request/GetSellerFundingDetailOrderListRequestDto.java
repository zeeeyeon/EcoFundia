package com.order.dto.funding.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetSellerFundingDetailOrderListRequestDto {
    private List<Integer> userIdList;
}
