package com.seller.client;

import com.seller.dto.request.GrantSellerRoleRequestDto;
import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(name="seller")
public interface SellerClient {

//    @GetMapping("/api/seller/check")
//    Boolean findByUserId(@RequestHeader("X-User-Id") int userId);

    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
//    @GetMapping("api/seller/info/funding-page/{sellerId}")
//    FundingDetailSellerResponseDto sellerInfo(@PathVariable int sellerId);
//
//    // 판매자 상세 정보 요청 조회
//    @GetMapping("api/seller/detail/{sellerID}")
//    String sellerDetail(@PathVariable int sellerId);
//
//    // 판매자 계좌 번호 조회
//    @GetMapping("api/seller/find/account")
//    SellerAccountResponseDto getSellerAccount(@RequestParam(name = "sellerId") int sellerId);
//
//    @PostMapping("/api/seller/seller-names")
//    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);
//
//    @PostMapping("api/seller/role")
//    ResponseEntity<?> grantSellerRole(@RequestHeader("X-User-Id") int userId, @RequestBody GrantSellerRoleRequestDto grantSellerRoleRequestDto);
//
//    @GetMapping("api/seller/total-amount")
//    ResponseEntity<?> getSellerTotalAmount(@RequestHeader("X-User-Id") int userId);
//
//    @GetMapping("api/seller/total-funding-count")
//    ResponseEntity<?> getSellerTotalFundingCount(@RequestHeader("X-User-Id") int userId);
//
//    @GetMapping("api/seller/today-order")
//    ResponseEntity<?> getSellerTodayOrderCount(@RequestHeader("X-User-Id") int userId);
//
//    @GetMapping("api/seller/ongoing/top")
//    ResponseEntity<?> getSellerOngoingTopFiveFunding(@RequestHeader("X-User-Id") int userId);
//
//    @GetMapping("api/seller/ongoing/list")
//    public ResponseEntity<?> getSellerOngoingFundingList(@RequestHeader("X-User-Id") int userId, @RequestParam(value = "page", defaultValue = "0") int page);
//
//    @GetMapping("api/seller/end/list")
//    public ResponseEntity<?> getSellerEndFundingList(@RequestHeader("X-User-Id") int userId, @RequestParam(value = "page", defaultValue = "0") int page);
//    @GetMapping("api/seller/today-order/list")
//    public ResponseEntity<?> getSellerTodayOrderTopThreeList(@RequestHeader("X-User-Id") int userId);
//
}
