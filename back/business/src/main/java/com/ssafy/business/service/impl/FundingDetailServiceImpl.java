package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.dto.ReviewDTO;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.ReviewResponseDTO;
import com.ssafy.business.service.FundingDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingDetailServiceImpl implements FundingDetailService {

    private final SellerClient sellerClient;
    private final FundingClient fundingClient;

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId){
        FundingResponseDTO fundingInfo = fundingClient.getFundingDetail(fundingId);
        FundingDetailSellerDTO sellerInfo = sellerClient.getSellerInfo(fundingInfo.getSellerId());
        return FundingDetailResponseDTO.from(fundingInfo, sellerInfo);
    }

    // 펀딩 리뷰 조회
    public ReviewResponseDTO getFundingReview(int sellerId, int page) {
        ReviewResponseDTO reviewList = fundingClient.getFundingReview(sellerId, page);
        return reviewList;
    }

}


