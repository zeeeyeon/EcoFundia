package com.ssafy.funding.dto.order.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class IsOngoingResponseDto {

    private Boolean isOngoing;
    private int sellerId;

    public static IsOngoingResponseDto of(Boolean isOngoing, int sellerId) {
        return IsOngoingResponseDto
                .builder()
                .isOngoing(isOngoing)
                .sellerId(sellerId)
                .build();
    }
}
