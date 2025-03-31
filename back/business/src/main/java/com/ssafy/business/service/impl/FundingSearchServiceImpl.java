package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.service.FundingSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingSearchServiceImpl implements FundingSearchService {

    private final FundingClient fundingClient;

    // 펀딩 키워드 검색 조회
    public List<FundingResponseDTO> getSearchFundingList(String sort, String keyword, int page){
        return fundingClient.getSearchFundingList(sort, keyword, page);
    }
}
