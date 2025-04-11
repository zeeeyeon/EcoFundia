package com.ssafy.funding.dto.funding.request;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AddCurrentAmountRequestDto {

    private int fundingId;
    private int amount;
}
