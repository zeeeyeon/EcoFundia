package com.ssafy.business.client;


import com.ssafy.business.dto.responseDTO.FundingWishCountResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "business")
public interface BusinessClient {

    // Top 펀딩 리스트 조회
    @GetMapping("/api/business/top-funding")
    ResponseEntity<?> getTopFundingList();

    // 현재까지 펀딩 금액 조회
    @GetMapping("/api/business/total-fund")
    ResponseEntity<Long> getTotalFund();

    // 최신 펀딩 리스트 조회
    @GetMapping("api/business/latest-funding/{page}")
    ResponseEntity<?> getLatestFundingList(@PathVariable int page);

    @GetMapping("/api/business/funding-page")
    ResponseEntity<?> getFundingPageList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "categories" ,required = false) List<String> categories,
            @RequestParam(name = "page") int page
    );

    // 카테고리별 펀딩 리스트 조회
    @GetMapping("api/business/category")
    ResponseEntity<?> getCategoryFundingList(@RequestParam(name="category") String category , @RequestParam(name="page") int page);

    // 펀딩 키워드 검색 조회
    @GetMapping("api/business/search")
    ResponseEntity<?> getSearchFundingList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name= "page") int page);

    // funding 서비스에서 검색페이지에 오늘의 펀딩, 마감임박 선택한 색션 펀딩 리스트 데이터 요청
    @GetMapping("api/business/search/special")
    List<FundingWishCountResponseDto> getSearchSpecialFunding(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "topic") String topic,
            @RequestParam(name= "page") int page);

    // 펀딩 상세 페이지
    @GetMapping("api/business/detail/{fundingId}")
    ResponseEntity<?> getFundingDetail(@PathVariable int fundingId);
    
    // 펀딩 리뷰 조회
    @GetMapping("api/business/review")
    ResponseEntity<?> getFundingDetail(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page);

    // 판매자 정보 조회
    @GetMapping("api/business/seller/detail/{sellerId}")
    ResponseEntity<?> getSellerDetail(@PathVariable int sellerId);

    // 판매자가 진행한 프로젝트 조회
    @GetMapping("api/business/seller/detail/{sellerId}/funding")
    ResponseEntity<?> getSellerFunding(@PathVariable int sellerId);
}
