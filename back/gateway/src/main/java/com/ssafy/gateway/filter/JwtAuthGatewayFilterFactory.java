package com.ssafy.gateway.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.List;

@Component
public class JwtAuthGatewayFilterFactory extends AbstractGatewayFilterFactory<JwtAuthGatewayFilterFactory.Config> {

    // secretKey는 application.yml에 정의된 값을 사용합니다.
    @Value("${spring.jwt.secret}")
    private String secretKey;

    public JwtAuthGatewayFilterFactory() {
        super(Config.class);
    }

    public static class Config {
        // 이 필드에 허용할 role을 지정합니다.
        private List<String> allowedRoles;
        public List<String> getAllowedRoles() { return allowedRoles; }
        public void setAllowedRoles(List<String> allowedRoles) { this.allowedRoles = allowedRoles; }
    }

    // JWT 서명 검증을 위한 Key 생성
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return unauthorized(exchange);
            }

            String token = authHeader.substring(7);
            Claims claims;
            try {
                claims = Jwts.parserBuilder()
                        .setSigningKey(getSigningKey())
                        .build()
                        .parseClaimsJws(token)
                        .getBody();
            } catch (JwtException e) {
                return unauthorized(exchange);
            }

            // JWT에서 role 추출 후 필터에 설정한 allowedRoles와 비교 (설정이 있다면)
            String tokenRole = claims.get("role", String.class);
            if (config.getAllowedRoles() != null && !config.getAllowedRoles().isEmpty()) {
                if (!config.getAllowedRoles().contains(tokenRole)) {
                    return forbidden(exchange);
                }
            }

            // JWT에서 userId 추출 (null 체크 포함)
            Object userIdObj = claims.get("userId");
            if (userIdObj == null) {
                return unauthorized(exchange);
            }
            String userId = userIdObj.toString();

            // 요청을 변경하여 downstream으로 전달할 때 인증 정보를 헤더에 추가
            ServerWebExchange modifiedExchange = exchange.mutate()
                    .request(exchange.getRequest().mutate()
                            .header("X-User-Id", userId)
                            .build())
                    .build();

            return chain.filter(modifiedExchange);
        };
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        exchange.getResponse().getHeaders().add(HttpHeaders.CONTENT_TYPE, "text/plain");
        String message = "Gateway Error: Unauthorized access - token missing or invalid";
        byte[] bytes = message.getBytes(StandardCharsets.UTF_8);
        DataBuffer buffer = exchange.getResponse().bufferFactory().wrap(bytes);
        return exchange.getResponse().writeWith(Mono.just(buffer));
    }

    private Mono<Void> forbidden(ServerWebExchange exchange) {
        exchange.getResponse().setStatusCode(HttpStatus.FORBIDDEN);
        exchange.getResponse().getHeaders().add(HttpHeaders.CONTENT_TYPE, "text/plain");
        String message = "Gateway Error: Forbidden - insufficient permissions";
        byte[] bytes = message.getBytes(StandardCharsets.UTF_8);
        DataBuffer buffer = exchange.getResponse().bufferFactory().wrap(bytes);
        return exchange.getResponse().writeWith(Mono.just(buffer));
    }
}
