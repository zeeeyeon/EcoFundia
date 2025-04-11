package com.ssafy.user.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReissueResponseDto {
    private String accessToken;
    private String refreshToken;
}
