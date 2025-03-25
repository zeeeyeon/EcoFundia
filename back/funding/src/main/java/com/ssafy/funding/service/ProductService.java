package com.ssafy.funding.service;

import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Status;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ProductService {
    Funding createFunding(int sellerId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
    FundingResponseDto getFunding(int fundingId);
    Funding updateFunding(int fundingId, FundingUpdateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
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

    // 펀딩 키워드 검색 조회
    List<GetFundingResponseDto> getSearchFundingList(String keyword, int page);

    // 펀딩 상세 페이지
    GetFundingResponseDto getFundingDetail(int fundingId);

    // 브랜드 만족도 조회
    ReviewResponseDto getFundingReview(int sellerId, int page);

    // 판매자 상세페이지 판매자 정보 요청 조회
    SellerDetailResponseDto getSellerDetail(int sellerId);

}
