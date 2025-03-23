package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.service.FundingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingServiceImpl implements FundingService {

    private final FundingClient fundingClient;

    // 현재까지 펀딩 금액 조회
    public Long getTotalFund(){
        return fundingClient.getTotalFund();
    }

    // Top 펀딩 리스트 조회
    public List<FundingResponseDTO> getTopFundingList(){
        return fundingClient.getTopFundingList();
    }

    // 최신 펀딩 리스트 조회
    public List<FundingResponseDTO> getLatestFundingList(int page){
        return fundingClient.getLatestFundingList(page);
    }

    // 카테고리별 펀딩 리스트 조회
    public List<FundingResponseDTO> getCategoryFundingList(String category, int page){
        return fundingClient.getCategoryFundingList(category, page);
    }
}


