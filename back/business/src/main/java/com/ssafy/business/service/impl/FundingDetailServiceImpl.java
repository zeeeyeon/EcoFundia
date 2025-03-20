package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingDetailSellerResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
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
        FundingDetailSellerResponseDTO sellerInfo = sellerClient.sellerInfo(fundingInfo.getSellerId());
        return FundingDetailResponseDTO.from(fundingInfo, sellerInfo);
    }

    // 펀딩 리뷰 조회
//    public ReviewResponseDTO getFundingReview(int sellerId, int page) {
//        List<ReviewDTO> reviewList = fundingClient.getFundingReview(sellerId, page);
//
//    }
//    // 펀딩 리뷰 조회
//    public ReviewResponseDTO getFundingReview(int sellerId, int page){
//        List<ReviewDTO> reviewList = fundingDetailMapper.getReviewList(sellerId, (page - 1) * 5); //지금 page안쓰고 있음
//
//        float totalRating = (float) reviewList.stream()
//                .mapToDouble(review -> (double) review.getRating()) // rating을 float으로 변환
//                .average()
//                .orElse(0.0);
//
//        /// Builder 사용하여 객체 생성
//        ReviewResponseDTO response = ReviewResponseDTO.builder()
//                .totalRating(totalRating)
//                .reviews(reviewList)
//                .build();
//
//        return response;
//    }
}


