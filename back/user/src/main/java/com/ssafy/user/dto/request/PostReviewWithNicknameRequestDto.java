package com.ssafy.user.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostReviewWithNicknameRequestDto {
    private int fundingId;
    private int rating;
    private String content;
    private String nickname;
}
