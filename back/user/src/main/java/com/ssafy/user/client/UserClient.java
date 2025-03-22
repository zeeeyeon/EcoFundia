package com.ssafy.user.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="user")
public interface UserClient {

}
