package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.GetFundingResponseDTO;

import java.util.List;

public  interface GetFundingService {

    // 전체 펀딩 금액 조회
    public Long getTotalFund();

    // Top 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getTopFundingList();

    // 최신 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getLatestFundingList(int page);

    // 카테고리별 펀딩 리스트 조회
    public List<GetFundingResponseDTO> getCategoryFundingList(String category, int page);

}
