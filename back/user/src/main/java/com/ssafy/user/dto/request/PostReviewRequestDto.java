package com.ssafy.user.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostReviewRequestDto {
    private int fundingId;
    private int rating;
    private String content;
}
