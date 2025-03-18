package com.ssafy.business.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "business")
public interface GetFundingClient {

    @GetMapping("/api/get/top-funding")
    ResponseEntity<?> getTopFundingList();

    @GetMapping("/api/get/total-fund")
    ResponseEntity<Long> getTotalFund();

    @GetMapping("api/get/latest-funding")
    ResponseEntity<?> getLatestFundingList();

    @GetMapping("api/get/category")
    ResponseEntity<?> getCategoryFundingList();
}
