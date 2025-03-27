package com.ssafy.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.StringRedisTemplate;

@Configuration
public class RedisConfig {

    /**
     * LettuceConnectionFactory 빈 생성.
     * Redis 서버와의 연결을 관리합니다.
     */
    @Bean
    public LettuceConnectionFactory redisConnectionFactory() {
        return new LettuceConnectionFactory();
    }

    /**
     * StringRedisTemplate 빈 생성.
     * 문자열 데이터를 Redis에 저장, 조회, 삭제하는 데 사용됩니다.
     */
    @Bean
    public StringRedisTemplate redisTemplate(LettuceConnectionFactory redisConnectionFactory) {
        return new StringRedisTemplate(redisConnectionFactory);
    }
}
