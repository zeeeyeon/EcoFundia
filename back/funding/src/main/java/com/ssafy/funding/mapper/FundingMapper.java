package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.Funding;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface FundingMapper {

    void createFunding(Funding funding);
    Funding findById(int fundingId);
    void updateFunding(Funding funding);
    void deleteFunding(int fundingId);


    // 현재까지 펀딩 금액 조회
    Long getTotalFund();

    // Top 펀딩 리스트 조회
    List<Funding> getTopFundingList();

    // 최신 펀딩 리스트 조회
    List<Funding> getLatestFundingList(int page);

    // 카테고리별 펀딩 리스트 조회
    List<Funding> getCategoryFundingList(@Param("category") String category, @Param("page") int page);

    List<Funding> getSearchFunding(@Param("keyword") String keyword, @Param("page") int page);
}
