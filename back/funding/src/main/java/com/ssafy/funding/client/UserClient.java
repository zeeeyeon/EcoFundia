package com.ssafy.funding.client;

import com.ssafy.funding.dto.seller.request.GetAgeListRequestDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "user")
public interface UserClient {
    @PostMapping("api/user/seller/age/list")
    List<Integer> getAgeList(@RequestBody List<GetAgeListRequestDto> dtos);
}
