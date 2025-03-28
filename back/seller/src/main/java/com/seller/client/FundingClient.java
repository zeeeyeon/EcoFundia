package com.seller.client;

import com.seller.config.FeignMultipartSupportConfig;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingCreateSendDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.request.FundingUpdateSendDto;
import com.seller.dto.response.*;
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
    ResponseEntity<?> createFunding(@PathVariable int sellerId, @RequestBody FundingCreateSendDto dto);

    @PutMapping(value = "/api/funding/{fundingId}")
    ResponseEntity<?> updateFunding(@PathVariable int fundingId, @RequestBody FundingUpdateSendDto dto);

    @DeleteMapping("/api/funding/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable int fundingId);

    @GetMapping("/api/funding/{fundingId}")
    FundingResponseDto getFundingById(@PathVariable("fundingId") int fundingId);
//
//    @PostMapping("/api/seller/sellerNames")
//    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);

    @GetMapping("/api/funding/seller/total-amount/{sellerId}")
    GetSellerTotalAmountResponseDto getSellerTotalAmount(@PathVariable("sellerId") int sellerId);

    @GetMapping("/api/funding/seller/total-funding/count/{sellerId}")
    GetSellerTotalFundingCountResponseDto getSellerTotalFundingCountResponseDto(@PathVariable("sellerId") int sellerId);

    @GetMapping("/api/funding/seller/today-order/{sellerId}")
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(@PathVariable("sellerId") int sellerId);

    @GetMapping("/api/funding/seller/ongoing/top/{sellerId}")
    List<GetSellerOngoingTopFiveFundingResponseDto> getSellerOngoingTopFiveFunding(@PathVariable("sellerId") int sellerId);

    @GetMapping("api/funding/seller/ongoing/list/{sellerId}")
    List<GetSellerOngoingFundingListResponseDto> getSellerOngoingFundingList(@PathVariable("sellerId") int sellerId, @RequestParam("page") int page);

    @GetMapping("api/funding/seller/end/list/{sellerId}")
    List<GetSellerEndFundingListResponseDto> getSellerEndFundingList(@PathVariable("sellerId") int sellerId, @RequestParam(value = "page", defaultValue = "0") int page);

    @GetMapping("api/funding/seller/today-order/list/{sellerId}")
    List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThreeList(@PathVariable("sellerId") int sellerId);
}
