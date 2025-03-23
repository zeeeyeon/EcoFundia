package com.order.dto.funding.response;

import lombok.Data;
import org.apache.ibatis.annotations.Param;

@Data
public class IsOngoingResponseDto {

    private Boolean isOngoing;
    private int sellerId;
}
