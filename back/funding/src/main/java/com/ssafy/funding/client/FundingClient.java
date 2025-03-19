package com.ssafy.funding.client;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

// Client 선언부, name 또는 url 사용 가능
// name or value 둘중 하나는 있어야 오류가 안남남
//@FeignClient(name = "funding-client", url = "http://localhost:8080")
//@FeignClient(name = "funding-service")
public interface FundingClient {


    @GetMapping("/api/funding")
    ResponseEntity<Object> getAllfunding();

    @GetMapping("/api/funding/{fundingId}")
    ResponseEntity<Object> getFunding(@PathVariable int fundingId);
}

