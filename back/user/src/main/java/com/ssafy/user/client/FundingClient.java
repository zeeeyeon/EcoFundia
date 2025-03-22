package com.ssafy.user.client;

import com.ssafy.user.dto.response.FundingResponseDto;
import com.ssafy.user.dto.response.GetMyTotalFundingResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import java.util.List;

@FeignClient(name = "funding-service")
public interface FundingClient {
    @GetMapping("/funding/my")
    List<FundingResponseDto> getMyFundings(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/funding/my/total")
    GetMyTotalFundingResponseDto getMyTotalFunding(@RequestHeader("X-User-Id") int userId);
}
