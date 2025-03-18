package com.ssafy.funding.model.service;

import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.model.entity.Funding;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingService implements FundingServiceImpl {

    private final FundingMapper fundingMapper;

    public List<Funding> getAllFunding() {
        return fundingMapper.getAllFunding();
    }

    public Funding getFundingById(int fundingId) {
        return fundingMapper.getFundingById(fundingId);
    }

}
