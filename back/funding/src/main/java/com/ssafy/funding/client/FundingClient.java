package com.ssafy.funding.client;

import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.order.response.IsOngoingResponseDto;
import com.ssafy.funding.dto.funding.response.UserWishlistFundingDto;
import com.ssafy.funding.dto.review.request.ReviewCreateRequestDto;
import com.ssafy.funding.dto.review.request.ReviewUpdateRequestDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Client 선언부, name 또는 url 사용 가능
// name or value 둘중 하나는 있어야 오류가 안남남
//@FeignClient(name = "funding-client", url = "http://localhost:8080")
@FeignClient(name = "funding")
public interface FundingClient {

    @GetMapping("/api/funding/{fundingId}")
    ResponseEntity<?> getFundingId(@PathVariable int fundingId);

    @PostMapping(value = "/api/funding/{sellerId}")
    ResponseEntity<?> createFunding(@PathVariable int sellerId, @RequestBody FundingCreateSendDto dto);

    @PutMapping(value = "/api/funding/{fundingId}")
    ResponseEntity<?> updateFunding(@PathVariable int fundingId, @RequestBody FundingUpdateRequestDto dto);

    @DeleteMapping("/api/funding/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable int fundingId);

    @GetMapping("/api/funding")
    ResponseEntity<Object> getAllfunding();

    @GetMapping("/api/funding/{fundingId}")
    ResponseEntity<Object> getFunding(@PathVariable int fundingId);


    // funding 서비스에게 top-funding 데이터 요청
    @GetMapping("/api/funding/top-funding")
    List<GetFundingResponseDto> getTopFundingList();

    // funding 서비스에게 최신 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/latest-funding")
    List<GetFundingResponseDto> getLatestFundingList(@RequestParam(name = "sortNum") int sortNum , @RequestParam(name = "page") int page);

    // funding 서비스에게 카테고리별 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/category")
    List<GetFundingResponseDto> getCategoryFundingList(@RequestParam(name = "category") String category , @RequestParam(name = "sortNum") int sortNum ,@RequestParam(name = "page") int page);

    // 펀딩 페이지 펀딩 리스트 조회
    @GetMapping("/api/funding/funding-page")
    List<GetFundingResponseDto>getFundingPageList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "categories" ,required = false) List<String> categories,
            @RequestParam(name = "page") int page
    );

    // funding 서비스에게 키워드 검색으로 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/search")
    List<GetFundingResponseDto> getSearchFundingList(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name= "page") int page);

    // funding 서비스에서 검색페이지에 오늘의 펀딩, 마감임박 선택한 색션 펀딩 리스트 데이터 요청
    @GetMapping("api/funding/search/special")
    List<FundingWishCountResponseDto> getSearchSpecialFunding(
            @RequestParam(name = "sort") String sort,
            @RequestParam(name = "topic") String topic,
            @RequestParam(name= "page") int page);

    // funding 서비스에게 펀딩 상세 정보 요청
    @GetMapping("api/funding/detail/{fundingId}")
    GetFundingResponseDto getFundingDetail(@PathVariable int fundingId);

    // funding 서비스에 펀딩 리뷰 조회
    @GetMapping("api/funding/review")
    ReviewResponseDto getFundingReview(@RequestParam(name="sellerId") int sellerId, @RequestParam(name="page") int page);

    // 판매자 상세페이지 판매자 정보 요청 조회
    @GetMapping("api/funding/seller/detail/{sellerId}")
    SellerDetailResponseDto getSellerDetail(@PathVariable int sellerId);

    // 결제전 현재 펀딩이 진행중인지 확인
    @GetMapping("api/funding/is-ongoing/{fundingId}")
    IsOngoingResponseDto isOngoing(@PathVariable int fundingId);

    @GetMapping("/api/review/user")
    List<ReviewDto> getReviewsByUserId(@RequestHeader("X-User-Id") String userId);

    @PostMapping("/api/review")
    ResponseEntity<?> createReview(@RequestHeader("X-User-Id") int userId, @RequestBody ReviewCreateRequestDto dto);

    @PutMapping("/api/review/{reviewId}")
    ResponseEntity<?> updateReview(@RequestHeader("X-User-Id") int userId,
                                   @PathVariable int reviewId,
                                   @RequestBody ReviewUpdateRequestDto dto);

    @RequestMapping(method = RequestMethod.DELETE, value = "/api/review/{reviewId}")
    ResponseEntity<?> deleteReview(@RequestHeader("X-User-Id") int userId,
                                   @PathVariable int reviewId);

    @PostMapping("/api/wishList/{fundingId}")
    ResponseEntity<?> createWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId);

    @GetMapping("/api/wishList/ongoing")
    List<UserWishlistFundingDto> getOngoingWishlist(@RequestHeader("X-User-Id") int userId);

    @GetMapping("/api/wishList/done")
    List<UserWishlistFundingDto> getDoneWishlist(@RequestHeader("X-User-Id") int userId);

    @DeleteMapping("/api/wishList/{fundingId}")
    ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId);

}

