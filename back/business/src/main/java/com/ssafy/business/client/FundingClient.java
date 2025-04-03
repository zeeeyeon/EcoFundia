package com.ssafy.business.client;

import com.ssafy.business.dto.responseDTO.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "funding")
public interface FundingClient {

    // 현재까지 펀딩 금액 조회
    @GetMapping("/api/funding/total-fund")
    Long getTotalFund();

    // funding 서비스에게 top-funding 데이터 요청
    @GetMapping("/api/funding/top-funding")
    List<FundingResponseDTO> getTopFundingList();

    // 펀딩 페이지 펀딩 리스트 조회
    @GetMapping("/api/funding/funding-page")
    List<FundingResponseDTO>getFundingPageList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "categories" ,required = false) List<String> categories,
            @RequestParam(name = "page") int page
    );

    // funding 서비스에게 최신 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/latest-funding/{page}")
    List<FundingResponseDTO> getLatestFundingList(@PathVariable int page);

    // funding 서비스에게 카테고리별 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/category")
    List<FundingResponseDTO> getCategoryFundingList(@RequestParam(name = "category") String category , @RequestParam(name = "page") int page);

    // funding 서비스에게 키워드 검색으로 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/search")
    List<FundingResponseDTO> getSearchFundingList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name= "page") int page);

    @GetMapping("api/funding/suggest")
    List<String> getSuggestions(@RequestParam("prefix") String prefix);

    // funding 서비스에서 검색페이지에 오늘의 펀딩, 마감임박 선택한 색션 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/search/special")
    List<FundingWishCountResponseDto> getSearchSpecialFunding(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "topic") String topic,
            @RequestParam(name= "page") int page);

    // funding 서비스에게 펀딩 상세 정보 요청
    @GetMapping("api/funding/detail/{fundingId}")
    FundingResponseDTO getFundingDetail(@PathVariable int fundingId);

    // funding 서비스에 펀딩 리뷰 조회
    @GetMapping("api/funding/review")
    ReviewResponseDTO getFundingReview(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page);

    // 판매자 상세페이지 판매자 정보 요청 조회
    @GetMapping("api/funding/seller/detail/{sellerId}")
    SellerDetailDTO getSellerDetail(@PathVariable int sellerId);

    @GetMapping("api/funding/seller/detail/{sellerId}/funding")
    SellerDetailDTO getSellerFunding(@PathVariable int sellerId);
}
