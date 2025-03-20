package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.mapper.FundingMapper;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.entity.Funding;
import com.ssafy.business.service.FundingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FundingServiceImpl implements FundingService {

    private final FundingMapper fundingMapper;
    private final FundingClient fundingClient;

    // 현재까지 펀딩 금액 조회
    public Long getTotalFund(){
        return fundingMapper.getTotalFund();
    }

    // Top 펀딩 리스트 조회
    public List<FundingResponseDTO> getTopFundingList(){
        //List<Funding> fundingList = fundingMapper.getTopFundingList();
        //return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
        return fundingClient.getTopFundingList();
    }

    // 최신 펀딩 리스트 조회
    public List<FundingResponseDTO> getLatestFundingList(int page){
        //List<Funding> fundingList = fundingMapper.getLatestFundingList((page - 1)  * 5);
        //return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
        return fundingClient.getLatestFundingList(page);
    }

    // 카테고리별 펀딩 리스트 조회
    public List<FundingResponseDTO> getCategoryFundingList(String category, int page){
        //List<Funding> fundingList = fundingMapper.getCategoryFundingList(category, (page - 1)  * 5);
        //return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
        return fundingClient.getCategoryFundingList(category, page);
    }
}


