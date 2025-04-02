package com.seller.controller;

import com.seller.common.response.PageResponse;
import com.seller.common.response.Response;
import com.seller.common.response.ResponseCode;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.request.GrantSellerRoleRequestDto;
import com.seller.dto.response.*;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/seller")
@RequiredArgsConstructor
public class SellerController {

    private final SellerService sellerService;

    @PostMapping(value = "/funding/registration", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> registrationFunding(
            @RequestHeader("X-User-Id") int userId,
            @RequestPart("dto") FundingCreateRequestDto dto,
            @RequestPart("storyFile") MultipartFile storyFile,
            @RequestPart("imageFiles") List<MultipartFile> imageFiles) {
        return sellerService.createFunding(userId, dto, storyFile, imageFiles);
    }

    @PutMapping(value = "/funding/{fundingId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateFunding(
            @PathVariable int fundingId,
            @RequestPart("dto") FundingUpdateRequestDto dto,
            @RequestPart(value = "storyFile", required = false) MultipartFile storyFile,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {
        return sellerService.updateFunding(fundingId, dto, storyFile, imageFiles);
    }

    @DeleteMapping("/funding/{fundingId}")
    public ResponseEntity<?> deleteFunding(@PathVariable int fundingId) {
        return sellerService.deleteFunding(fundingId);
    }

    @GetMapping("/check")
    public Boolean findByUserId(@RequestHeader("X-User-Id") int userId) {
        return sellerService.findByUserId(userId);
    }

    @PostMapping("/seller-names")
    public Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds) {
        log.info("getSellerNames: {}", sellerIds);
        return sellerService.getNamesByIds(sellerIds);
    }


    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("/info/funding-page/{sellerId}")
    FundingDetailSellerResponseDto sellerInfo(@PathVariable("sellerId") int sellerId){
        FundingDetailSellerResponseDto sellerInfo = sellerService.sellerInfo(sellerId);
        return sellerInfo;
    }

    // 판매자 상세 정보 요청 조회
    @GetMapping("/detail/{sellerID}")
    String sellerDetail(@PathVariable("sellerId") int sellerId){
        return null;
    }

    // 판매자 계좌 번호 조회
    @GetMapping("api/seller/find/account")
    SellerAccountResponseDto getSellerAccount(@RequestParam(name = "sellerId") int sellerId){
        SellerAccountResponseDto sellerAccountResponseDto = sellerService.getSellerAccount(sellerId);
        return sellerAccountResponseDto;
    }

    @PostMapping("/role")
    public ResponseEntity<?> grantSellerRole(@RequestHeader("X-User-Id") int userId, @RequestBody GrantSellerRoleRequestDto grantSellerRoleRequestDto) {
        sellerService.grantSellerRole(userId, grantSellerRoleRequestDto);
        return new ResponseEntity<>(Response.create(ResponseCode.GRANT_SELLER_ROLE, null), ResponseCode.GRANT_SELLER_ROLE.getHttpStatus());
    }

    @GetMapping("/total-amount")
    public ResponseEntity<?> getSellerTotalAmount(@RequestHeader("X-User-Id") int userId) {
        GetSellerTotalAmountResponseDto dto = sellerService.getSellerTotalAmount(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_TOTAL_AMOUNT, dto), ResponseCode.GET_SELLER_TOTAL_AMOUNT.getHttpStatus());
    }

    @GetMapping("/total-funding/count")
    public ResponseEntity<?> getSellerTotalFundingCount(@RequestHeader("X-User-Id") int userId) {
        GetSellerTotalFundingCountResponseDto dto = sellerService.getSellerTotalFundingCount(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_TOTAL_FUNDING_COUNT, dto), ResponseCode.GET_SELLER_TOTAL_FUNDING_COUNT.getHttpStatus());
    }

    @GetMapping("/today-order")
    public ResponseEntity<?> getSellerTodayOrderCount(@RequestHeader("X-User-Id") int userId) {
        GetSellerTodayOrderCountResponseDto dto = sellerService.getSellerTodayOrderCount(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_TODAY_ORDER_COUNT, dto), ResponseCode.GET_SELLER_TOTAL_FUNDING_COUNT.getHttpStatus());
    }

    @GetMapping("/ongoing/top")
    public ResponseEntity<?> getSellerOngoingTopFiveFunding(@RequestHeader("X-User-Id") int userId) {
        List<GetSellerOngoingTopFiveFundingResponseDto> dto = sellerService.getSellerOngoingTopFiveFunding(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_ONGOING_TOP_FIVE_FUNDING, dto), ResponseCode.GET_SELLER_TOTAL_FUNDING_COUNT.getHttpStatus());
    }

    @GetMapping("/ongoing/list")
    public ResponseEntity<?> getSellerOngoingFundingList(@RequestHeader("X-User-Id") int userId, @RequestParam(value = "page", defaultValue = "0") int page) {
        List<GetSellerOngoingFundingListResponseDto> dto = sellerService.getSellerOngoingFundingList(userId, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_ONGOING_FUNDING_LIST, dto), ResponseCode.GET_SELLER_ONGOING_FUNDING_LIST.getHttpStatus());
    }

    @GetMapping("/end/list")
    public ResponseEntity<?> getSellerEndFundingList(@RequestHeader("X-User-Id") int userId, @RequestParam(value = "page", defaultValue = "0") int page) {
        List<GetSellerEndFundingListResponseDto> dto = sellerService.getSellerEndFundingList(userId, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_END_FUNDING_LIST, dto), ResponseCode.GET_SELLER_END_FUNDING_LIST.getHttpStatus());
    }

    @GetMapping("/funding/detail/{fundingId}")
    public ResponseEntity<?> getSellerFundingDetail(@PathVariable("fundingId") int fundingId) {
        GetSellerFundingDetailResponseDto dto = sellerService.getSellerFundingDetail(fundingId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_FUNDING_DETAIL, dto), ResponseCode.GET_SELLER_FUNDING_DETAIL.getHttpStatus());
    }

    @GetMapping("/funding/detail/order/{fundingId}")
    public ResponseEntity<?> getSellerFundingDetailOrderList(@PathVariable("fundingId") int fundingId, @RequestParam(value = "page", defaultValue = "0") int page) {
        List<GetSellerFundingDetailOrderListResponseDto> dto = sellerService.getSellerFundingDetailOrderList(fundingId, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_FUNDING_DETAIL_ORDER_LIST, dto), ResponseCode.GET_SELLER_FUNDING_DETAIL_ORDER_LIST.getHttpStatus());
    }

    @GetMapping("/month-amount-statistics")
    public ResponseEntity<?> getSellerMonthAmountStatistics(@RequestHeader("X-User-Id") int userId) {
        List<GetSellerMonthAmountStatisticsResponseDto> dto = sellerService.getSellerMonthAmountStatistics(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_MONTH_AMOUNT_STATISTICS, dto), ResponseCode.GET_SELLER_MONTH_AMOUNT_STATISTICS.getHttpStatus());
    }

    @GetMapping("/funding/detail/statistics/{fundingId}")
    public ResponseEntity<?> getSellerFundingDetailStatistics(@PathVariable("fundingId") int fundingId) {
        List<GetSellerFundingDetailStatisticsResponseDto> dto = sellerService.getSellerFundingDetailStatistics(fundingId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_FUNDING_DETAIL_STATISTICS, dto), ResponseCode.GET_SELLER_FUNDING_DETAIL_STATISTICS.getHttpStatus());
    }

    @GetMapping("/brand-statistics")
    public ResponseEntity<?> getSellerBrandStatistics(@RequestHeader("X-User-Id") int userId) {
        List<GetSellerBrandStatisticsResponseDto> dto = sellerService.getSellerBrandStatistics(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_BRAND_STATISTICS, dto), ResponseCode.GET_SELLER_BRAND_STATISTICS.getHttpStatus());
    }

    @GetMapping("/today-order/list")
    public ResponseEntity<?> getSellerTodayOrderTopThree(@RequestHeader("X-User-Id") int userId) {
        List<GetSellerTodayOrderTopThreeListResponseDto> dto = sellerService.getSellerTodayOrderTopThree(userId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_TODAY_ORDER_TOP_THREE_LIST, dto), ResponseCode.GET_SELLER_TODAY_ORDER_TOP_THREE_LIST.getHttpStatus());
    }

    @GetMapping("/settlements/completed-fundings")
    public ResponseEntity<?> getCompletedFundings(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(name = "page",defaultValue = "0") int page,
            @RequestParam(name = "size",defaultValue = "5") int size){
        PageResponse<GetCompletedFundingsResponseDto> dto = sellerService.getCompletedFundings(userId,page,size);

        return new ResponseEntity<>(Response.create(ResponseCode.GET_Completed_FUNDING, dto), ResponseCode.GET_Completed_FUNDING.getHttpStatus());
    }
}
