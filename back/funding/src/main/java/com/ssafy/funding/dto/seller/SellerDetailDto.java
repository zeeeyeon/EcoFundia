package com.ssafy.funding.dto.seller;

import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.entity.SellerDetail;
import com.ssafy.funding.entity.enums.Status;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class SellerDetailDto {

    private int fundingId;
    private String title;
    private String description;
    private List<String> imageUrls;
    private int price;
    private int targetAmount;
    private int currentAmount;
    private LocalDateTime endDate;
    private Status status;

    private int totalRating; // rating
    private int ratingCount; // 만족도에 사용된 rating 개수

    private int wishlistCount; // 찜 개수

    public static SellerDetailDto toDto(SellerDetail sellerDetail) {
        return SellerDetailDto.builder()
                .fundingId(sellerDetail.getFundingId())
                .title(sellerDetail.getTitle())
                .description(sellerDetail.getDescription())
                .imageUrls(JsonConverter.convertJsonToImageUrls(sellerDetail.getImageUrls()))
                .price(sellerDetail.getPrice())
                .targetAmount(sellerDetail.getTargetAmount())
                .currentAmount(sellerDetail.getCurrentAmount())
                .endDate(sellerDetail.getEndDate())
                .status(sellerDetail.getStatus())
                .totalRating(sellerDetail.getTotalRating())
                .ratingCount(sellerDetail.getRatingCount())
                .wishlistCount(sellerDetail.getWishlistCount())
                .build();
    }
}
