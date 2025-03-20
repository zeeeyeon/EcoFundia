package com.seller.service.impl;

import com.seller.dto.FundingDetailSellerResponseDto;
import com.seller.mapper.SellerMapper;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerMapper sellerMapper;

    // 펀딩 상세페이지 seller 정보 조회
    public FundingDetailSellerResponseDto sellerInfo(int sellerId) {
        FundingDetailSellerResponseDto sellerInfo = sellerMapper.sellerInfo(sellerId);
        return sellerInfo;
    }
}
