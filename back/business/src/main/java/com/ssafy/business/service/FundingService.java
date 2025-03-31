package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;

import java.util.List;

public  interface FundingService {

    // 전체 펀딩 금액 조회
    Long getTotalFund();

    // Top 펀딩 리스트 조회
    List<FundingResponseDTO> getTopFundingList();

    // 최신 펀딩 리스트 조회
    List<FundingResponseDTO> getLatestFundingList(int page);

    // 카테고리별 펀딩 리스트 조회
    List<FundingResponseDTO> getCategoryFundingList(String category, int page);

    // 펀딩 페이지 펀딩 조회
    List<FundingResponseDTO> getFundingPageList(String sort, List<String> categories ,int page);


}
