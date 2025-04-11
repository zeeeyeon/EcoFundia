package com.ssafy.user.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignupRequestDto {
    private String token;
    private String nickname;
    private String gender;
    private int age;
}
