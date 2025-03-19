package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingReviewResponseDTO;

import java.util.List;

public interface FundingDetailService {

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId);

    // 펀딩 리뷰 조회
    public List<FundingReviewResponseDTO> getFundingReview(int fundingId, int page);


}
