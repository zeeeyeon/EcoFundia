package com.ssafy.funding.service;

import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateSendDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Status;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ProductService {
    FundingResponseDto getFunding(int fundingId);
    Funding createFunding(int sellerId, FundingCreateSendDto dto);
    Funding updateFunding(int fundingId, FundingUpdateSendDto dto);
    void deleteFunding(int fundingId);
    Status getFundingStatus(int fundingId);

    // 전체 펀딩 금액 조회
    Long getTotalFund();

    // Top 펀딩 리스트 조회
    List<GetFundingResponseDto> getTopFundingList();

    // 최신 펀딩 리스트 조회
    List<GetFundingResponseDto> getLatestFundingList(int page);

    // 카테고리별 펀딩 리스트 조회
    List<GetFundingResponseDto> getCategoryFundingList(String category, int page);

    // 펀딩 페이지 펀딩 리스트 조회
    List<GetFundingResponseDto> getFundingPageList(String sort, int page, List<String> categories);

    // 펀딩 키워드 검색 조회
    List<GetFundingResponseDto> getSearchFundingList(String sort, String keyword, int page);

    // 펀딩 검색페이지 토픽 검색 (오늘의 펀딩 마감임박, 오늘의 검색어)
    List<FundingWishCountResponseDto> getSearchSpecialFunding(String sort , String topic, int page);

    // 펀딩 상세 페이지
    GetFundingResponseDto getFundingDetail(int fundingId);

    // 브랜드 만족도 조회
    ReviewResponseDto getFundingReview(int sellerId, int page);

    // 판매자 상세페이지 판매자 정보 요청 조회
    SellerDetailResponseDto getSellerDetail(int sellerId);

}
