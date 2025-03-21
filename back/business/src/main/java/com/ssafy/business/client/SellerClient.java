package com.ssafy.business.client;

import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "seller")
public interface SellerClient {

    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("api/seller/info/funding-page/{sellerId}")
    FundingDetailSellerDTO sellerInfo(@PathVariable int sellerId);

    // 판매자 상세페이지 판매자 정보 요청 조회
    @GetMapping("api/seller/detail/{sellerID}")
    SellerDetailResponseDTO sellerDetail(@PathVariable int sellerId);

}
