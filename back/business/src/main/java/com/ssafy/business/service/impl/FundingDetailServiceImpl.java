package com.ssafy.business.service.impl;

import com.ssafy.business.dto.FundingDetailDTO;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.ReviewDTO;
import com.ssafy.business.dto.responseDTO.ReviewResponseDTO;
import com.ssafy.business.mapper.FundingDetailMapper;
import com.ssafy.business.service.FundingDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingDetailServiceImpl implements FundingDetailService {

    private final FundingDetailMapper fundingDetailMapper;

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId){
        FundingDetailDTO fundingDetail = fundingDetailMapper.getFundingDetail(fundingId);
        return fundingDetail.toDto();
    }

    // 펀딩 리뷰 조회
    public ReviewResponseDTO getFundingReview(int sellerId, int page){
        List<ReviewDTO> reviewList = fundingDetailMapper.getReviewList(sellerId, (page - 1) * 5); //지금 page안쓰고 있음

        float totalRating = (float) reviewList.stream()
                .mapToDouble(review -> (double) review.getRating()) // rating을 float으로 변환
                .average()
                .orElse(0.0);

        /// Builder 사용하여 객체 생성
        ReviewResponseDTO response = ReviewResponseDTO.builder()
                .totalRating(totalRating)
                .reviews(reviewList)
                .build();

        return response;
    }
}


