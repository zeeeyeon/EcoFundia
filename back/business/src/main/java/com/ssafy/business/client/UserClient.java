package com.ssafy.business.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@FeignClient(name = "user")
public interface UserClient {

//    @GetMapping("api/user/info/review-page")
//    List<UserClient> getUserInfo()
}
