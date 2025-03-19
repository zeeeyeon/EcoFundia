package com.ssafy.funding.service;

import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.entity.Funding;

public interface ProductService {
    Funding createFunding(int sellerId, FundingCreateRequestDto dto);
    FundingResponseDto getFunding(int fundingId);
}
