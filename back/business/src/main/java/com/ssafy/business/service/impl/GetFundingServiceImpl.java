package com.ssafy.business.service.impl;

import com.ssafy.business.mapper.GetFundingMapper;
import com.ssafy.business.dto.GetFundingResponseDTO;
import com.ssafy.business.entity.Funding;
import com.ssafy.business.service.GetFundingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GetFundingServiceImpl implements GetFundingService {

    private final GetFundingMapper getFundingMapper;

    // 현재까지 펀딩 금액 조회
    public Long getTotalFund(){
        return getFundingMapper.getTotalFund();
    }

    // Top 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getTopFundingList(){
        List<Funding> fundingList = getFundingMapper.getTopFundingList();
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());

    }

    // 최신 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getLatestFundingList(){
        List<Funding> fundingList = getFundingMapper.getLatestFundingList();
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }
}


