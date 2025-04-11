package com.ssafy.business.dto;

import lombok.Data;

@Data
public class ReviewDTO {

    private int reviewId;
    private int rating;
    private String content;

    private int userId;
    private String nickname;

    private int fundingId;
    private String title;

}
