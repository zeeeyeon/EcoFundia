package com.ssafy.funding.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class Review {
    private int reviewId;
    private int userId;
    private int fundingId;
    private int rating;
    private String content;
    private String nickname;
    private LocalDateTime createdAt;
    
    // ALTER TABLE review ADD CONSTRAINT unique_user_funding_review UNIQUE (user_id, funding_id);
    @Builder
    public Review(int userId, int fundingId, int rating, String content, String nickname) {
        this.userId = userId;
        this.fundingId = fundingId;
        this.rating = rating;
        this.content = content;
        this.nickname = nickname;
        this.createdAt = LocalDateTime.now();
    }

    public void update(String content, int rating) {
        this.content = content;
        this.rating = rating;
        this.createdAt = LocalDateTime.now();
    }
}

