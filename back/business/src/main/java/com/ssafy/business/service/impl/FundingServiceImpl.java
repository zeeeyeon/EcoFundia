package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.common.exception.CustomException;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.service.FundingService;
import lombok.RequiredArgsConstructor;
import org.bouncycastle.math.ec.custom.sec.SecT113Field;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static com.ssafy.business.common.response.ResponseCode.*;

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

        List<FundingResponseDTO> fundingList = fundingClient.getTopFundingList();

        if (fundingList == null || fundingList.size() == 0) {
            throw new CustomException(CURRENT_NOT_FUNDING);
        }

        return fundingList;
    }

    // 최신 펀딩 리스트 조회
    public List<FundingResponseDTO> getLatestFundingList(int page){
        if (page <= 0) {
            page = 1;
        }
        List<FundingResponseDTO> fundingList = fundingClient.getLatestFundingList(page);
        if (fundingList == null || fundingList.size() == 0) {
            throw new CustomException(DATA_NOT_FOUND);
        }
        return fundingList;
    }

    // 카테고리별 펀딩 리스트 조회
    public List<FundingResponseDTO> getCategoryFundingList(String category, int page){
        if (page <= 0) {
            page = 1;
        }
        List<FundingResponseDTO> fundingList = fundingClient.getCategoryFundingList(category, page);
        if (fundingList == null || fundingList.size() == 0) {
            throw new CustomException(DATA_NOT_FOUND);
        }
        return fundingList;
    }

    // 카테고리 목록
    private static final Set<String> VALID_CATEGORIES = new HashSet<>(
            Arrays.asList("FASHION", "ELECTRONICS", "HOUSEHOLD", "INTERIOR", "FOOD")
    );

    public List<FundingResponseDTO> getFundingPageList(String sort, List<String> categories ,int page) {

        if (page <= 0) {
            page = 1;
        }
        // "categories" :  //전체일때는 없이 FASHION, ELECTRONICS, HOUSEHOLD, INTERIOR, FOOD
        if (categories != null) {
            Long categoriesSize = categories.stream().filter(VALID_CATEGORIES::contains).count();

            if (categoriesSize < categories.size()) {
                throw new CustomException(CATEGORIES_BAD_REQUEST);
            }

        }
        List<FundingResponseDTO> fundingList = fundingClient.getFundingPageList(sort, categories, page);

        if (fundingList == null || fundingList.size() == 0) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }
        return fundingList;
    }
}


