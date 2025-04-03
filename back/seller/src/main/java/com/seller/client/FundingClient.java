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

    @PostMapping(value = "/api/funding/{sellerId}")
    ResponseEntity<?> createFunding(@PathVariable("sellerId") int sellerId, @RequestBody FundingCreateSendDto dto);

    @PutMapping(value = "/api/funding/{fundingId}")
    ResponseEntity<?> updateFunding(@PathVariable("fundingId") int fundingId, @RequestBody FundingUpdateSendDto dto);

    @DeleteMapping("/api/funding/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable("fundingId") int fundingId);

    @GetMapping("/api/funding/{fundingId}")
    FundingResponseDto getFundingById(@PathVariable("fundingId") int fundingId);

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

    @GetMapping("api/funding/seller/funding/detail/{fundingId}")
    GetSellerFundingDetailResponseDto getSellerFundingDetail(@PathVariable("fundingId") int fundingId);

    @GetMapping("api/funding/seller/month-amount-statistics/{sellerId}")
    List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(@PathVariable("sellerId") int sellerId);

    @GetMapping("api/funding/seller/brand-statistics/{sellerId}")
    List<GetSellerBrandStatisticsResponseDto> getSellerBrandStatistics(@PathVariable("sellerId") int sellerId);

    @GetMapping("api/funding/seller/today-order/list/{sellerId}")
    List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThree(@PathVariable("sellerId") int sellerId);
//
//    @PostMapping("/api/seller/sellerNames")
//    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);

    @PostMapping("/api/funding/update-event-sent")
    void updateSettlementCompleted(@RequestParam("fundingId") int fundingId, @RequestParam("eventSent") Boolean eventSent);

    @GetMapping("/api/funding/seller/completed-funding/{sellerId}")
    List<GetCompletedFundingsAtFundingResponseDto> getCompletedFundings(@PathVariable("sellerId") int sellerId);

    @GetMapping("/api/funding/seller/settlements/expected-fundings/{sellerId}")
    GetExpectedSettlementsResponseDto getExpectedSettlements(@PathVariable("sellerId") int sellerId);
}
