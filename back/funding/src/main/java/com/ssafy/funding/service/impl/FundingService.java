package com.ssafy.funding.service.impl;

import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.response.ResponseCode;
import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FundingService implements ProductService {

    private final FundingMapper fundingMapper;

    @Override
    @Transactional
    public Funding createFunding(int sellerId, FundingCreateRequestDto dto) {
        Funding funding = dto.toEntity(sellerId);
        fundingMapper.createFunding(funding);

        return funding;
    }

    @Override
    public FundingResponseDto getFunding(int fundingId) {
        Funding funding = findByFundingId(fundingId);

        return FundingResponseDto.fromEntity(funding);
    }

    @Override
    @Transactional
    public Funding updateFunding(int fundingId, FundingUpdateRequestDto dto) {
        Funding funding = findByFundingId(fundingId);

        funding.applyUpdate(dto);
        fundingMapper.updateFunding(funding);
        return funding;
    }

    private Funding findByFundingId(int fundingId) {
        Funding funding = fundingMapper.findById(fundingId);
        if (funding == null) throw new CustomException(ResponseCode.FUNDING_NOT_FOUND);
        return funding;
    }
}
