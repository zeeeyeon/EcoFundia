package com.ssafy.funding.dto.review.response;

import lombok.Data;

@Data
public class ReviewDto {

    private int reviewId;
    private int rating;
    private String content;

    private int userId;
    private String nickname;

    private int fundingId;
    private String title;
}