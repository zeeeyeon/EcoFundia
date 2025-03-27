package com.ssafy.user.service.impl;

import com.ssafy.user.service.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class RedisServiceImpl implements RedisService {

    private final StringRedisTemplate redisTemplate;

    /**
     * Redis에 지정된 키–값 데이터를 저장합니다.
     * @param key 저장할 키 (예: "refreshToken:{userId}")
     * @param value 저장할 값 (예: 해싱된 refresh token)
     * @param expirationMillis 만료 시간 (밀리초 단위)
     */
    @Override
    public void setValue(String key, String value, long expirationMillis) {
        redisTemplate.opsForValue().set(key, value, expirationMillis, TimeUnit.MILLISECONDS);
    }

    @Override
    public String getValue(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    @Override
    public void deleteValue(String key) {
        redisTemplate.delete(key);
    }
}
