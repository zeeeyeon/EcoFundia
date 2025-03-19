package com.ssafy.business.controller;


import com.ssafy.business.common.response.Response;
import com.ssafy.business.common.response.ResponseCode;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.ReviewResponseDTO;
import com.ssafy.business.service.FundingDetailService;
import com.ssafy.business.service.impl.FundingDetailServiceImpl;
import com.ssafy.business.service.impl.FundingSearchServiceImpl;
import com.ssafy.business.service.impl.FundingServiceImpl;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/business")
@RequiredArgsConstructor
public class FundingController {

    private final FundingServiceImpl GetFundingService;
    private final FundingSearchServiceImpl FundingSearchService;
    private final FundingDetailServiceImpl FundingDetailService;

    // Top 펀딩 리스트 조회
    @GetMapping("/top-funding")
    public ResponseEntity<?> getTopFundingList() {
        List<FundingResponseDTO> fundingList = GetFundingService.getTopFundingList();
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 현재까지 펀딩 금액 조회
    @GetMapping("/total-fund")
    public ResponseEntity<?> getTotalFund() {
        Long totalFund = GetFundingService.getTotalFund();
        return new ResponseEntity<>(Response.create(ResponseCode.GET_TOTAL_FUNDING, totalFund), ResponseCode.GET_TOTAL_FUNDING.getHttpStatus());
    }

    // 최신 펀딩 리스트 조회
    @GetMapping("/latest-funding/{page}")
    public ResponseEntity<?> getLatestFundingList(@PathVariable int page) {
        List<FundingResponseDTO> fundingList = GetFundingService.getLatestFundingList(page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 카테고리별 펀딩 리스트 조회
    @GetMapping("/funding/category")
    public ResponseEntity<?> getCategoryFundingList(@RequestParam(name="category") String category , @RequestParam(name="page") int page) {
        List<FundingResponseDTO> fundingList = GetFundingService.getCategoryFundingList(category, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 펀딩 키워드 검색 조회
    @GetMapping("/funding/search")
    public ResponseEntity<?> getSearchFundingList(@RequestParam(name="keyword") String keyword, @RequestParam(name="page") int page){
        List<FundingResponseDTO> fundingList = FundingSearchService.getSearchFundingList(keyword, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 펀딩 상세 페이지
    @GetMapping("/funding/detail/{fundingId}")
    public ResponseEntity<?> getFundingDetail(@PathVariable int fundingId) {
        FundingDetailResponseDTO fundingDetail = FundingDetailService.getFundingDetail(fundingId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING_DETAIL, fundingDetail), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    @GetMapping("/review")
    public ResponseEntity<?> getFundingDetail(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page) {
        ReviewResponseDTO fundingDetail = FundingDetailService.getFundingReview(sellerId, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING_DETAIL, fundingDetail), ResponseCode.GET_FUNDING.getHttpStatus());
    }

}