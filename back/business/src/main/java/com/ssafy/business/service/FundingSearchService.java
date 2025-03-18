package com.ssafy.business.service;

import com.ssafy.business.dto.responseDTO.GetFundingResponseDTO;

import java.util.List;

public interface FundingSearchService {

    // 펀딩 키워드 검색 조회
    public List<GetFundingResponseDTO> getSearchFundingList(String keyword, int page);


}
