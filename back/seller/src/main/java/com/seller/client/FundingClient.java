package com.seller.client;

import com.seller.config.FeignMultipartSupportConfig;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingCreateSendDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.request.FundingUpdateSendDto;
import com.seller.dto.response.FundingResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@FeignClient(name = "funding", configuration = FeignMultipartSupportConfig.class)
public interface FundingClient {

//    @GetMapping("/api/funding/{fundingId}")
//    ResponseEntity<?> getFundingId(@PathVariable int fundingId);
//
    @PostMapping(value = "/api/funding/{sellerId}")
    ResponseEntity<?> createFunding(@PathVariable("sellerId") int sellerId, @RequestBody FundingCreateSendDto dto);

    @PutMapping(value = "/api/funding/{fundingId}")
    ResponseEntity<?> updateFunding(@PathVariable("fundingId") int fundingId, @RequestBody FundingUpdateSendDto dto);

    @DeleteMapping("/api/funding/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable("fundingId") int fundingId);

    @GetMapping("/api/funding/{fundingId}")
    FundingResponseDto getFundingById(@PathVariable("fundingId") int fundingId);
//
//    @PostMapping("/api/seller/sellerNames")
//    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);

    @PostMapping("/api/funding/update-event-sent")
    void updateSettlementCompleted(@RequestParam("fundingId") int fundingId, @RequestParam("eventSent") Boolean eventSent);
}
