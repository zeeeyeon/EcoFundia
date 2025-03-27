package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateSendDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.funding.response.MyFundingResponseDto;
import com.ssafy.funding.dto.order.response.IsOngoingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.service.OrderService;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/funding")
@RequiredArgsConstructor
public class FundingController {

    private final ProductService productService;
    private final OrderService orderService;

    //내가 주문한 펀딩 프로젝트 조회
    @GetMapping("/my/funding")
    List<MyFundingResponseDto> getMyFunding(@RequestParam List<Integer> fundingIds){
        List<MyFundingResponseDto> fundingList = productService.getMyFunding(fundingIds);
        return fundingList;
    }

    @GetMapping("/{fundingId}")
    public ResponseEntity<?> getFundingId(@PathVariable int fundingId) {
        FundingResponseDto funding = productService.getFunding(fundingId);
        return new ResponseEntity<>(Response.create(GET_FUNDING, funding), GET_FUNDING.getHttpStatus());
    }

    @PostMapping(value = "/{sellerId}")
    public ResponseEntity<?> createFunding(@PathVariable int sellerId, @RequestBody FundingCreateSendDto dto) {
        productService.createFunding(sellerId, dto);
        return new ResponseEntity<>(Response.create(CREATE_FUNDING, null), CREATE_FUNDING.getHttpStatus());
    }

    @PutMapping(value = "/{fundingId}")
    public ResponseEntity<?> updateFunding(@PathVariable int fundingId, @RequestBody FundingUpdateSendDto dto) {
        productService.updateFunding(fundingId, dto);
        return new ResponseEntity<>(Response.create(UPDATE_FUNDING, null), UPDATE_FUNDING.getHttpStatus());
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteFunding(@PathVariable int fundingId) {
        productService.deleteFunding(fundingId);
        return new ResponseEntity<>(Response.create(DELETE_FUNDING, null), DELETE_FUNDING.getHttpStatus());
    }

    // 현재까지 펀딩 금액 조회
    @GetMapping("/total-fund")
    public Long getTotalFund() {
        Long totalFund = productService.getTotalFund();
        return totalFund;
    }

    // funding 서비스에게 top-funding 데이터 요청
    @GetMapping("/top-funding")
    List<GetFundingResponseDto> getTopFundingList() {
        List<GetFundingResponseDto> fundingList = productService.getTopFundingList();
        return fundingList;
    }

    // funding 서비스에게 최신 펀딩 리스트 데이터 요청
    @GetMapping("/latest-funding/{page}")
    List<GetFundingResponseDto> getLatestFundingList(@RequestParam(name = "sortNum") String sortNum , @RequestParam(name = "page") int page) {
        List<GetFundingResponseDto> fundingList = productService.getLatestFundingList(page);
        return fundingList;
    }

    // funding 서비스에게 카테고리별 펀딩 리스트 데이터 요청
    @GetMapping("/category")
    List<GetFundingResponseDto> getCategoryFundingList(@RequestParam(name = "category") String category , @RequestParam(name = "sortNum") String sortNum, @RequestParam(name = "page") int page) {
        List<GetFundingResponseDto> fundingList = productService.getCategoryFundingList(category, page);
        return fundingList;
    }

    // 펀딩 페이지 펀딩 리스트 조회
    @GetMapping("/funding-page")
    List<GetFundingResponseDto>getFundingPageList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "categories" ,required = false) List<String> categories,
            @RequestParam(name = "page") int page
    ) {
        List<GetFundingResponseDto> fundingList = productService.getFundingPageList(sort, page, categories);
        return fundingList;
    }

    //funding 서비스에게 키워드 검색으로 펀딩 리스트 데이터 요청
    @GetMapping("/search")
    List<GetFundingResponseDto> getSearchFundingList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name= "page") int page) {
        List<GetFundingResponseDto> fundingList = productService.getSearchFundingList(sort ,keyword, page);
        return fundingList;
    }

    // funding 서비스에서 검색페이지에 배스트 펀딩, 마감임박, 오늘의 검색어 중 선택한 색션 펀딩 리스트 데이터 요청
    @GetMapping("/search/special")
    List<FundingWishCountResponseDto> getSearchSpecialFunding(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "topic") String topic,
            @RequestParam(name= "page") int page) {
        List<FundingWishCountResponseDto> fundingList = productService.getSearchSpecialFunding(sort ,topic, page);
        return fundingList;
    }

    // 펀딩 프로젝트 상세 정보 요청
    @GetMapping("/detail/{fundingId}")
    GetFundingResponseDto getFundingDetail(@PathVariable int fundingId) {
        GetFundingResponseDto fundingResponseDto = productService.getFundingDetail(fundingId);
        return fundingResponseDto;
    }

    // 펀딩 리뷰 조회
    @GetMapping("/review")
    ReviewResponseDto getFundingReview(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page){
        ReviewResponseDto reviewResponseDto = productService.getFundingReview(sellerId, page);
        return reviewResponseDto;
    }

    // 판매자 상세정보 조회
    @GetMapping("/seller/detail/{sellerId}")
    SellerDetailResponseDto getSellerDetail(@PathVariable int sellerId){
        SellerDetailResponseDto sellerDetailResponseDto = productService.getSellerDetail(sellerId);
        return sellerDetailResponseDto;
    }

    // 결제전 현재 펀딩이 진행중인지 확인
    @GetMapping("/is-ongoing/{fundingId}")
    IsOngoingResponseDto isOngoing(@PathVariable int fundingId) {
        IsOngoingResponseDto isOngoingResponseDto = orderService.isOngoing(fundingId);
        return isOngoingResponseDto;
    }
}
