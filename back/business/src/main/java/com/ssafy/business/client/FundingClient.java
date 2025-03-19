package com.ssafy.business.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "business")
public interface FundingClient {

    // Top 펀딩 리스트 조회
    @GetMapping("/api/business/top-funding")
    ResponseEntity<?> getTopFundingList();

    // 현재까지 펀딩 금액 조회
    @GetMapping("/api/business/total-fund")
    ResponseEntity<Long> getTotalFund();

    // 최신 펀딩 리스트 조회
    @GetMapping("api/business/latest-funding/{page}")
    ResponseEntity<?> getLatestFundingList(@PathVariable int page);

    // 카테고리별 펀딩 리스트 조회
    @GetMapping("api/business/funding/category")
    ResponseEntity<?> getCategoryFundingList(@RequestParam(name="category") String category , @RequestParam(name="page") int page);

    // 펀딩 키워드 검색 조회
    @GetMapping("/funding/search")
    public ResponseEntity<?> getSearchFundingList(@RequestParam(name="keyword") String keyword, @RequestParam(name="page") int page);

    // 펀딩 상세 페이지
    @GetMapping("/funding/detail/{fundingId}")
    public ResponseEntity<?> getFundingDetail(@PathVariable int fundingId);

    @GetMapping("/review")
    public ResponseEntity<?> getFundingDetail(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page);
}
