package com.ssafy.user.entity;

import lombok.*;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    private int userId;
    private String email;
    private String name;
    private String nickname;
    private String gender; // ENUM 대신 String으로 저장 (MyBatis에서 변환 처리 가능)
    private String account;
    private String ssafyUserKey;
    private int age;
    private LocalDateTime createdAt;
}
