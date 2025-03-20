package com.ssafy.business.dto.responseDTO;


import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class FundingDetailResponseDTO {

    private FundingResponseDTO fundingInfo;
    private FundingDetailSellerResponseDTO sellerInfo;

    // 정적 팩토리 메서드 추가 (DTO 생성 메서드)
    public static FundingDetailResponseDTO from(FundingResponseDTO funding, FundingDetailSellerResponseDTO seller) {
        return FundingDetailResponseDTO.builder()
                .fundingInfo(funding)
                .sellerInfo(seller)
                .build();
    }
}
