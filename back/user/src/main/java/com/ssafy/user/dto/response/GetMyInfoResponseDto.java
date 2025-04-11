package com.ssafy.user.dto.response;

import com.ssafy.user.entity.User;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetMyInfoResponseDto {
    private User user;
}
