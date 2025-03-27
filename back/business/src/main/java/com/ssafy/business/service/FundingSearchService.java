package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingWishCountResponseDto;

import java.util.List;

public interface FundingSearchService {

    // 펀딩 키워드 검색 조회
    List<FundingResponseDTO> getSearchFundingList(String sort, String keyword, int page);

    // 베스트 , 마감임박 펀딩 조회
    List<FundingWishCountResponseDto> getSearchSpecialFunding(String sort , String topic, int page);
}
