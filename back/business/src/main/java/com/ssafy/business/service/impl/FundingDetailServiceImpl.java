package com.ssafy.business.service.impl;

import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingReviewResponseDTO;
import com.ssafy.business.entity.Review;
import com.ssafy.business.mapper.FundingDetailMapper;
import com.ssafy.business.service.FundingDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FundingDetailServiceImpl implements FundingDetailService {

    private final FundingDetailMapper fundingDetailMapper;

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId){
        return fundingDetailMapper.getFundingDetail(fundingId);
    }

    // 펀딩 리뷰 조회
    public List<FundingReviewResponseDTO> getFundingReview(int fundingId, int page){
        List<Review> reviewList = fundingDetailMapper.getReviewList(fundingId, page);
        return reviewList.stream().map(Review::toDto).collect(Collectors.toList());
    }
}


