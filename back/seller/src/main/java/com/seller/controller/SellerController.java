package com.seller.controller;

import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/seller")
@RequiredArgsConstructor
public class SellerController {

    private final SellerService sellerService;

    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("/info/funding-page/{sellerId}")
    FundingDetailSellerResponseDto sellerInfo(@PathVariable int sellerId){
        FundingDetailSellerResponseDto sellerInfo = sellerService.sellerInfo(sellerId);
        return sellerInfo;
    }

    // 판매자 상세 정보 요청 조회
    @GetMapping("/detail/{sellerID}")
    String sellerDetail(@PathVariable int sellerId){
        return null;
    }
}
