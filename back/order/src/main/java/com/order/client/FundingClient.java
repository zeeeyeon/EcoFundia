package com.order.client;

import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.funding.response.IsOngoingResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "funding" )
public interface FundingClient {

    @GetMapping("api/funding/is-ongoing/{fundingId}")
    IsOngoingResponseDto isOngoing(@PathVariable int fundingId);

    @GetMapping("api/funding")
    List<FundingResponseDto> getMyFunding(@RequestBody List<Integer> fundingIds);
}
