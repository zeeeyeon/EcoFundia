package com.order.client;

import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.funding.response.IsOngoingResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "funding" )
public interface FundingClient {

    @GetMapping("api/funding/is-ongoing/{fundingId}")
    IsOngoingResponseDto isOngoing(@PathVariable("fundingId") int fundingId);

    @GetMapping("api/funding/my/funding")
    List<FundingResponseDto> getMyFunding(@RequestParam("fundingIds") List<Integer> fundingIds);

    @GetMapping("api/funding/total-fund")
    Long getTotalFund();
}
