package com.ssafy.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // ✅ 최신 방식으로 변경
                .cors(Customizer.withDefaults()) // 🔹 Security에서도 CORS 허용
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/user/login",
                                "/api/user/signup",
                                "/api/user/reissue",
                                "/api/user/health"
                        ).permitAll() // 🔹 인증 없이 접근 가능 API
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll() // 🔹 OPTIONS 요청 허용
                        .anyRequest().authenticated() // 🔹 나머지는 인증 필요
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS) // 🔹 JWT 인증 사용
                );

        return http.build();
    }
}
