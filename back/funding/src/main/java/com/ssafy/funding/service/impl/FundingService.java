package com.ssafy.funding.service.impl;

import com.ssafy.funding.dto.request.FundingCreateRequestDto;
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
    private final ProductService productService;

    @Override
    @Transactional
    public Funding createFunding(int sellerId, FundingCreateRequestDto dto) {
        Funding funding = dto.toEntity(sellerId);
        fundingMapper.createFunding(funding);
        return funding;
    }
}
