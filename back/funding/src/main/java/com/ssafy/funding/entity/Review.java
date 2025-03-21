package com.ssafy.funding.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Review {
    private int reviewId;
    private int fundingId;
    private int rating;
    private String content;
    private String nickname;
}

