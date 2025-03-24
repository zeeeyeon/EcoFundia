package com.seller.service.impl;

import com.seller.dto.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import com.seller.entity.Seller;
import com.seller.mapper.SellerMapper;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerMapper sellerMapper;

    // 펀딩 상세페이지 seller 정보 조회
    @Transactional
    public FundingDetailSellerResponseDto sellerInfo(int sellerId) {
        FundingDetailSellerResponseDto sellerInfo = sellerMapper.sellerInfo(sellerId);
        return sellerInfo;
    }

    // 판매자 계좌 번호 조회
    @Transactional
    public SellerAccountResponseDto getSellerAccount(int sellerId){
        Seller seller = sellerMapper.getSeller(sellerId);

        if (seller == null){
            return SellerAccountResponseDto.of("0","0");
        }
        return SellerAccountResponseDto.of(seller.getAccount(), seller.getSsafyUserKey());
    }
}
