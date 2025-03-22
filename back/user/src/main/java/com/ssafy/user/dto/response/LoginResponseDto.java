package com.ssafy.user.dto.response;

import com.ssafy.user.entity.User;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponseDto {
    private String accessToken;
    private String refreshToken;
    private User user;
    private String role;
}
