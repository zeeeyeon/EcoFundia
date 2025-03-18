package com.ssafy.business.controller;

import com.ssafy.business.service.impl.FundingSearchServiceImpl;
import com.ssafy.business.service.impl.GetFundingServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/get")
@RequiredArgsConstructor
public class GetFundingController {

    private final GetFundingServiceImpl GetFundingService;
    private final FundingSearchServiceImpl FundingSearchService;

    // Top 펀딩 리스트 조회
    @GetMapping("/top-funding")
    public ResponseEntity<?> getTopFundingList() {
        return ResponseEntity.ok(GetFundingService.getTopFundingList());
    }

    // 현재까지 펀딩 금액 조회
    @GetMapping("/total-fund")
    public ResponseEntity<Long> getTotalFund() {
            return ResponseEntity.ok(GetFundingService.getTotalFund());
    }

    // 최신 펀딩 리스트 조회
    @GetMapping("/latest-funding/{page}")
    public ResponseEntity<?> getLatestFundingList(@PathVariable int page) {
        return ResponseEntity.ok(GetFundingService.getLatestFundingList(page));
    }

    // 카테고리별 펀딩 리스트 조회
    @GetMapping("/funding/category")
    public ResponseEntity<?> getTotalFund(@RequestParam(name="category") String category , @RequestParam(name="page") int page) {
        return ResponseEntity.ok(GetFundingService.getCategoryFundingList(category, page));
    }

    // 펀딩 키워드 검색 조회
    @GetMapping("/funding/search")
    public ResponseEntity<?> getSearchFundingList(@RequestParam(name="keyword") String keyword, @RequestParam(name="page") int page){
        return ResponseEntity.ok(FundingSearchService.getSearchFundingList(keyword, page));
    }

    // 펀딩 상세 페이지
    @GetMapping("/funding/detail/{fundingId}")
    public ResponseEntity<?> getFundingDetail(@PathVariable int fundingId) {
        return ResponseEntity.ok(1);
    }

}