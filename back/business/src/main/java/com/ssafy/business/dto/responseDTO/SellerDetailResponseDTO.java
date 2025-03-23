package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.SellerFundingDTO;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SellerDetailResponseDTO {

    private int sellerId;
    private String sellerName;
    private String sellerProfileImageUrl;

    // 판매자의 펀딩 통계 및 펀딩 리스트
    private float totalRating;
    private int ratingCount;
    private int totalAmount;
    private int wishlistCount;

    private List<SellerFundingDTO> onGoingFunding;
    private List<SellerFundingDTO> finishFunding;


    public static SellerDetailResponseDTO from(FundingDetailSellerDTO sellerInfo, SellerDetailDTO sellerDetail) {
        return SellerDetailResponseDTO.builder()
                .sellerId(sellerInfo.getSellerId())
                .sellerName(sellerInfo.getSellerName()) // 현재 null 가능
                .sellerProfileImageUrl(sellerInfo.getSellerProfileImageUrl())

                .totalRating(sellerDetail.getTotalRating())
                .ratingCount(sellerDetail.getRatingCount())
                .totalAmount(sellerDetail.getTotalAmount())
                .wishlistCount(sellerDetail.getWishlistCount())
                .onGoingFunding(sellerDetail.getOnGoingFunding())
                .finishFunding(sellerDetail.getFinishFunding())

                .build();
    }
}
