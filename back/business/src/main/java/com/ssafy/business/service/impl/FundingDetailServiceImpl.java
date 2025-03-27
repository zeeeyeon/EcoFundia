package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.common.exception.CustomException;
import com.ssafy.business.dto.ReviewDTO;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.ReviewResponseDTO;
import com.ssafy.business.service.FundingDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import static com.ssafy.business.common.response.ResponseCode.*;
@Service
@RequiredArgsConstructor
public class FundingDetailServiceImpl implements FundingDetailService {

    private final SellerClient sellerClient;
    private final FundingClient fundingClient;

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId){
        FundingResponseDTO fundingInfo = fundingClient.getFundingDetail(fundingId);
        if (fundingInfo == null) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }
        FundingDetailSellerDTO sellerInfo = sellerClient.getSellerInfo(fundingInfo.getSellerId());
        if (sellerInfo == null) {
            throw new CustomException(SELLER_NOT_FOUND);
        }
        return FundingDetailResponseDTO.from(fundingInfo, sellerInfo);
    }

    // 펀딩 리뷰 조회
    public ReviewResponseDTO getFundingReview(int sellerId, int page) {

        ReviewResponseDTO reviewList = fundingClient.getFundingReview(sellerId, page);

        if (reviewList == null) {
            throw new CustomException(REVIEW_NOT_FOUND);
        }
        return reviewList;
    }

}


