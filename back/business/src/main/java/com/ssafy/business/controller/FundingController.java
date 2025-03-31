package com.ssafy.business.controller;


import com.ssafy.business.client.SellerClient;
import com.ssafy.business.common.response.Response;
import com.ssafy.business.common.response.ResponseCode;
import com.ssafy.business.dto.responseDTO.*;
import com.ssafy.business.service.FundingDetailService;
import com.ssafy.business.service.impl.FundingDetailServiceImpl;
import com.ssafy.business.service.impl.FundingSearchServiceImpl;
import com.ssafy.business.service.impl.FundingServiceImpl;
import com.ssafy.business.service.impl.SellerServiceImpl;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/business")
@RequiredArgsConstructor
public class FundingController {

    private final FundingServiceImpl fundingService;
    private final FundingSearchServiceImpl fundingSearchService;
    private final FundingDetailServiceImpl fundingDetailService;
    private final SellerServiceImpl sellerService;

    // Top 펀딩 리스트 조회
    @GetMapping("/top-funding")
    public ResponseEntity<?> getTopFundingList() {
        List<FundingResponseDTO> fundingList = fundingService.getTopFundingList();
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 현재까지 펀딩 금액 조회
    @GetMapping("/total-fund")
    public ResponseEntity<?> getTotalFund() {
        Long totalFund = fundingService.getTotalFund();
        return new ResponseEntity<>(Response.create(ResponseCode.GET_TOTAL_FUNDING, totalFund), ResponseCode.GET_TOTAL_FUNDING.getHttpStatus());
    }

    // 최신 펀딩 리스트 조회
    @GetMapping("/latest-funding/{page}")
    public ResponseEntity<?> getLatestFundingList(@PathVariable int page) {
        List<FundingResponseDTO> fundingList = fundingService.getLatestFundingList(page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 카테고리별 펀딩 리스트 조회
    @GetMapping("/category")
    public ResponseEntity<?> getCategoryFundingList(@RequestParam(name="category") String category , @RequestParam(name="page") int page) {
        List<FundingResponseDTO> fundingList = fundingService.getCategoryFundingList(category, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 펀딩 페이지 펀딩 조회
    @GetMapping("/funding-page")
    public ResponseEntity<?> getFundingPageList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "categories" ,required = false) List<String> categories,
            @RequestParam(name = "page") int page
    ) {
        List<FundingResponseDTO> fundingList = fundingService.getFundingPageList(sort, categories, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 펀딩 키워드 검색 조회
    @GetMapping("/search")
    public ResponseEntity<?> getSearchFundingList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name= "page") int page){
        List<FundingResponseDTO> fundingList = fundingSearchService.getSearchFundingList(sort, keyword, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING, fundingList), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 펀딩 상세 페이지
    @GetMapping("/detail/{fundingId}")
    public ResponseEntity<?> getFundingDetail(@PathVariable int fundingId) {
        FundingDetailResponseDTO fundingDetail = fundingDetailService.getFundingDetail(fundingId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING_DETAIL, fundingDetail), ResponseCode.GET_FUNDING.getHttpStatus());
    }
    // 펀딩 리뷰 조회
    @GetMapping("/review")
    public ResponseEntity<?> getFundingReview(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page) {
        ReviewResponseDTO fundingDetail = fundingDetailService.getFundingReview(sellerId, page);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_FUNDING_REVIEW, fundingDetail), ResponseCode.GET_FUNDING.getHttpStatus());
    }

    // 판매자 상세 정보 조회 (판매자 상세페이지 데이터 조회)
    @GetMapping("seller/detail/{sellerId}")
    public ResponseEntity<?> getSellerDetail(@PathVariable int sellerId) {
        SellerDetailResponseDTO sellerDetail = sellerService.getSellerDetail(sellerId);
        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_DETAIL, sellerDetail), ResponseCode.GET_SELLER_DETAIL.getHttpStatus());
    }

    //판매자 프로젝트 현황 조회 - 판매자가 진행중 혹은 진행한 프로젝트 데이터 조회
//    @GetMapping("seller/detail/{sellerId}/funding")
//    ResponseEntity<?> getSellerFunding(@PathVariable int sellerId) {
//        SellerFundingResponseDTO sellerFunding = sellerService.getSellerDetail(sellerId);
//        return new ResponseEntity<>(Response.create(ResponseCode.GET_SELLER_FUNDING, sellerFunding), ResponseCode.GET_SELLER_FUNDING.getHttpStatus());
//    }


}

