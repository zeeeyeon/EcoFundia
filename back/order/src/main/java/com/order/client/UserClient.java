package com.order.client;

import com.order.dto.funding.request.GetAgeListRequestDto;
import com.order.dto.funding.request.GetSellerFundingDetailOrderListRequestDto;
import com.order.dto.user.response.GetSellerFundingDetailOrderUserInfoListResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import java.util.List;

@FeignClient(name = "user")
public interface UserClient {
    @PostMapping("api/user/seller/funding/detail/order")
    List<GetSellerFundingDetailOrderUserInfoListResponseDto> getSellerFundingDetailOrderList(@RequestBody GetSellerFundingDetailOrderListRequestDto getSellerFundingDetailOrderListRequestDto);

    @PostMapping("api/user/seller/age/list")
    List<Integer> getAgeList(@RequestBody List<GetAgeListRequestDto> dtos);
}
