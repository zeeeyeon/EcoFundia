package com.ssafy.business.dto.responseDTO;


import com.ssafy.business.dto.FundingDetailSellerDTO;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FundingDetailResponseDTO {

    private FundingResponseDTO fundingInfo;
    private FundingDetailSellerDTO sellerInfo;

    // 정적 팩토리 메서드 추가 (DTO 생성 메서드)
    public static FundingDetailResponseDTO from(FundingResponseDTO funding, FundingDetailSellerDTO seller) {
        return FundingDetailResponseDTO.builder()
                .fundingInfo(funding)
                .sellerInfo(seller)
                .build();
    }
}
