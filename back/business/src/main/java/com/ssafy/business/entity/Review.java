package com.ssafy.business.entity;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingReviewResponseDTO;
import lombok.Getter;

@Getter
public class Review {

    private int reviewId;
    private int fundingId;
    private int userId;
    private int rating; //1~5점
    private String content;

    public FundingReviewResponseDTO toDto() {
        return FundingReviewResponseDTO
                .builder()
                .reviewId(reviewId)
                .fundingId(fundingId)
                .userId(userId)
                .rating(rating)
                .content(content)
                .build();
    }
}

