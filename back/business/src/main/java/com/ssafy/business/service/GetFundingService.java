package com.ssafy.business.service;

import com.ssafy.business.dto.GetFundingResponseDTO;

import java.util.List;

public  interface GetFundingService {

    // 전체 펀딩 금액 조회
    public Long getTotalFund();

    // Top 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getTopFundingList();

    // 최신 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getLatestFundingList();
}
