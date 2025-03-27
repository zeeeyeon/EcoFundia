package com.ssafy.user.service;

public interface RedisService {

    void setValue(String key, String value, long expirationMillis);

    String getValue(String key);

    void deleteValue(String key);
}
