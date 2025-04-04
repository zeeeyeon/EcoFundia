package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.common.exception.CustomException;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingWishCountResponseDto;
import com.ssafy.business.dto.responseDTO.SuggestionResponseDto;
import com.ssafy.business.service.FundingSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import static com.ssafy.business.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class FundingSearchServiceImpl implements FundingSearchService {

    private final FundingClient fundingClient;

    // 펀딩 키워드 검색 조회
    public List<FundingResponseDTO> getSearchFundingList(String sort, String keyword, int page){

        if ( sort == null || (!sort.equals("latest") && !sort.equals("oldest") && !sort.equals("popular"))){
            throw new CustomException(SORT_BAD_REQUEST);
        }

        List<FundingResponseDTO> fundingList = fundingClient.getSearchFundingList(sort, keyword, page);

        if (fundingList == null || fundingList.size() == 0) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }

        return fundingList;
    }

    // 베스트 , 마감임박 펀딩 조회
    public List<FundingWishCountResponseDto> getSearchSpecialFunding(String sort , String topic, int page){

        if ( sort == null || (!sort.equals("none") && !sort.equals("latest") && !sort.equals("oldest") && !sort.equals("popular"))){
            throw new CustomException(SORT_BAD_REQUEST);
        }
        if ( topic == null || (!topic.equals("best") && !topic.equals("soon") && !topic.equals("daily"))){
            throw new CustomException(TOPIC_BAD_REQUEST);
        }

        List<FundingWishCountResponseDto> funingList = fundingClient.getSearchSpecialFunding(sort, topic, page);

        if (funingList == null || funingList.size() == 0) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }
        return funingList;
    }

    @Override
    public List<SuggestionResponseDto> getAutoCompleteSuggestions(String prefix) {
        List<String> suggestions = fundingClient.getSuggestions(prefix);
        List<SuggestionResponseDto> dto = new ArrayList<>();
        for(String s : suggestions){
            SuggestionResponseDto temp = new SuggestionResponseDto(s);
            dto.add(temp);
        }
        return dto;
    }
}
