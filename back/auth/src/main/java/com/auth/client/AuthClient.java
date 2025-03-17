package com.auth.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name = "auth-service")
public interface AuthClient {
}
