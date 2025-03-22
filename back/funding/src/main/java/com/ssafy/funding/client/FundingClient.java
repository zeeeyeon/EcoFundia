package com.ssafy.funding.client;

import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

// Client 선언부, name 또는 url 사용 가능
// name or value 둘중 하나는 있어야 오류가 안남남
//@FeignClient(name = "funding-client", url = "http://localhost:8080")
@FeignClient(name = "funding")
public interface FundingClient {


    @GetMapping("/api/funding")
    ResponseEntity<Object> getAllfunding();

    @GetMapping("/api/funding/{fundingId}")
    ResponseEntity<Object> getFunding(@PathVariable int fundingId);

    // funding 서비스에게 top-funding 데이터 요청
    @GetMapping("/api/funding/top-funding")
    List<GetFundingResponseDto> getTopFundingList();

    // funding 서비스에게 최신 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/latest-funding/{page}")
    List<GetFundingResponseDto> getLatestFundingList(@PathVariable int page);

    // funding 서비스에게 카테고리별 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/category")
    List<GetFundingResponseDto> getCategoryFundingList(@RequestParam(name = "category") String category , @RequestParam(name = "page") int page);

    // funding 서비스에게 키워드 검색으로 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/search")
    List<GetFundingResponseDto> getSearchFundingList(@RequestParam(name = "keyword") String keyword, @RequestParam(name= "page") int page);

    // funding 서비스에게 펀딩 상세 정보 요청
    @GetMapping("api/funding/detail/{fundingId}")
    GetFundingResponseDto getFundingDetail(@PathVariable int fundingId);

    // funding 서비스에 펀딩 리뷰 조회
    @GetMapping("api/funding/review")
    ReviewResponseDto getFundingReview(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page);

    // 판매자 상세페이지 판매자 정보 요청 조회
    @GetMapping("api/funding/seller/detail/{sellerId}")
    SellerDetailResponseDto getSellerDetail(@PathVariable int sellerId);


}

