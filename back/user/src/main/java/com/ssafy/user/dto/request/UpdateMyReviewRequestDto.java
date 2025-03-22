package com.ssafy.user.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateMyReviewRequestDto {
    private int rating;
    private String content;
}
