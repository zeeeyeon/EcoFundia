package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;

import java.util.List;

public interface FundingSearchService {

    // 펀딩 키워드 검색 조회
    List<FundingResponseDTO> getSearchFundingList(String sort, String keyword, int page);

}
