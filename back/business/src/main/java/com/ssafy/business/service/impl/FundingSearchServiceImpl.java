package com.ssafy.business.service.impl;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.entity.Funding;
import com.ssafy.business.mapper.FundingSearchMapper;
import com.ssafy.business.service.FundingSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FundingSearchServiceImpl implements FundingSearchService {

    private final FundingSearchMapper fundingSearchMapper;

    // 펀딩 키워드 검색 조회
    public List<FundingResponseDTO> getSearchFundingList(String keyword, int page){
        List<Funding> fundingList = fundingSearchMapper.getSearchFunding(keyword, page);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }
}
