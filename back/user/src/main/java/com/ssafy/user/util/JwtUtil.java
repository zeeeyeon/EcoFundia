package com.ssafy.user.util;

import com.ssafy.user.common.exception.CustomException;
import com.ssafy.user.common.response.ResponseCode;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import com.ssafy.user.entity.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${spring.jwt.secret}")
    private String SECRET_KEY;

    @Value("${spring.jwt.access-token-expiration}")
    private long ACCESS_TOKEN_EXPIRATION;

    @Value("${spring.jwt.refresh-token-expiration}")
    private long REFRESH_TOKEN_EXPIRATION;

    // SECRET_KEY 문자열을 Key 객체로 변환
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(User user, String role) {
        return Jwts.builder()
                .setSubject(user.getEmail()) // email을 subject로 설정
                .claim("userId", user.getUserId())
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String generateRefreshToken(User user) {
        return Jwts.builder()
                .setSubject(user.getEmail()) // Refresh Token도 email 기반
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + REFRESH_TOKEN_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            throw new CustomException(ResponseCode.INVALID_ACCESS_TOKEN);
        }
    }

    public String extractEmail(String token) {
        return Jwts.parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject(); // Subject = email
    }

    public int extractUserId(String token) {
        Claims claims = Jwts.parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        // claim으로 저장된 userId를 Integer로 반환
        return (Integer) claims.get("userId");
    }

    public long getRefreshTokenExpiration() {
        return REFRESH_TOKEN_EXPIRATION;
    }
}
