package com.notification.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "funding")
public interface FundingClient {
    @GetMapping("/api/funding/total-fund")
    Long getTotalFund();
}
