package com.seller.client;

import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@FeignClient(name="seller")
public interface SellerClient {

//    @GetMapping("/api/seller/check")
//    Boolean findByUserId(@RequestHeader("X-User-Id") int userId);

    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("api/seller/info/funding-page/{sellerId}")
    FundingDetailSellerResponseDto sellerInfo(@PathVariable int sellerId);

    // 판매자 상세 정보 요청 조회
    @GetMapping("api/seller/detail/{sellerID}")
    String sellerDetail(@PathVariable int sellerId);

    // 판매자 계좌 번호 조회
    @GetMapping("api/seller/find/account")
    SellerAccountResponseDto getSellerAccount(@RequestParam(name = "sellerId") int sellerId);

    @PostMapping("/api/seller/seller-names")
    Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds);


}
