package com.ssafy.user.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="user-service")
public class UserClient {
}
