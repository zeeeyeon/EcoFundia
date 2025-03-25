package com.seller.client;

import com.seller.dto.response.FundingDetailSellerResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name="seller")
public interface SellerClient {

    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("api/seller/info/funding-page/{sellerId}")
    FundingDetailSellerResponseDto sellerInfo(@PathVariable int sellerId);

    // 판매자 상세 정보 요청 조회
    @GetMapping("api/seller/detail/{sellerID}")
    String sellerDetail(@PathVariable int sellerId);
}
