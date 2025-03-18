package com.ssafy.business.service.impl;

import com.ssafy.business.mapper.FundingSearchMapper;
import com.ssafy.business.mapper.GetFundingMapper;
import com.ssafy.business.dto.responseDTO.GetFundingResponseDTO;
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
    public List<GetFundingResponseDTO> getLatestFundingList(int page){
        List<Funding> fundingList = getFundingMapper.getLatestFundingList(page);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }

    // 카테고리별 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getCategoryFundingList(String category, int page){
        List<Funding> fundingList = getFundingMapper.getCategoryFundingList(category, page);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }
}


