package com.ssafy.funding.mapper;

import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.seller.SellerDetailDto;
import com.ssafy.funding.entity.Funding;
import org.apache.ibatis.annotations.*;
import org.springframework.web.bind.annotation.PathVariable;

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

    // 펀딩 페이지 펀딩 조회
    List<Funding> getFundingPageList(
            @Param("sort") String sort,
            @Param("categories") List<String> categories,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 펀딩 키워드 검색 조회
    List<Funding> getSearchFundingList(
            @Param("sort") String sort,
            @Param("keyword") String keyword,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 최신 펀딩 리스트 조회
    List<Funding> getLatestFundingList(int page);

    // 카테고리별 펀딩 리스트 조회
    List<Funding> getCategoryFundingList(@Param("category") String category, @Param("page") int page);

    // 브랜드 만족도 조회
    List<ReviewDto> getReviewList(@Param("sellerId") int sellerId, @Param("page") int page);

    List<SellerDetailDto> getSellerDetail(@PathVariable int sellerId);
}
