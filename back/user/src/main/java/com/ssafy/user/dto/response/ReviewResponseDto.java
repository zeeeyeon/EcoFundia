package com.ssafy.user.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReviewResponseDto {
    private int reviewId;
    private int rating;
    private String content;
    private String nickname;
    private int userId;
    private int fundingId;
    private String title;
}
