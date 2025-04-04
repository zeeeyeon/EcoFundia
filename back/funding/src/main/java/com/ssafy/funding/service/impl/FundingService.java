package com.ssafy.funding.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.funding.client.OrderClient;
import com.ssafy.funding.client.UserClient;
import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.document.FundingDocument;
import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateSendDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.funding.response.MyFundingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.dto.seller.request.GetAgeListRequestDto;
import com.ssafy.funding.dto.seller.request.GetSellerTodayOrderCountRequestDto;
import com.ssafy.funding.dto.seller.response.*;
import com.ssafy.funding.elasticsearch.ElasticsearchService;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.FundingWishCount;
import com.ssafy.funding.entity.SellerDetail;
import com.ssafy.funding.entity.enums.Status;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static com.ssafy.funding.common.response.ResponseCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class FundingService implements ProductService {
    private final OrderClient orderClient;
    private final FundingMapper fundingMapper;
    private final ElasticsearchService elasticsearchService;
    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;
    private final UserClient userClient;

    private static final int PAGE_SIZE = 5;
    private static final String TOTAL_FUND_KEY = "total_fund";

    @Override
    public FundingResponseDto getFunding(int fundingId) {
        Funding funding = findByFundingId(fundingId);
        return FundingResponseDto.fromEntity(funding);
    }


    @Override
    @Transactional
    public Funding createFunding(int sellerId, FundingCreateSendDto dto) {
        Funding funding = dto.toEntity(sellerId);
        fundingMapper.createFunding(funding);
        elasticsearchService.indexFunding(funding);
        return funding;
    }

    @Override
    @Transactional
    public Funding updateFunding(int fundingId, FundingUpdateSendDto dto) {
        Funding funding = findByFundingId(fundingId);
        funding.update(dto);
        fundingMapper.updateFunding(funding);
        elasticsearchService.indexFunding(funding);
        return funding;
    }

    @Override
    public void deleteFunding(int fundingId) {
        findByFundingId(fundingId);
        fundingMapper.deleteFunding(fundingId);
        elasticsearchService.deleteFunding(fundingId);
    }

    private Funding findByFundingId(int fundingId) {
        Funding funding = fundingMapper.findById(fundingId);
        if (funding == null) throw new CustomException(FUNDING_NOT_FOUND);
        return funding;
    }

    @Override
    public Status getFundingStatus(int fundingId) {
        Funding funding = findByFundingId(fundingId);
        return funding.getStatus();
    }

    // 현재까지 펀딩 금액 조회
    @Transactional
    public Long getTotalFund(){
        String cachedFund = redisTemplate.opsForValue().get(TOTAL_FUND_KEY);
        if(cachedFund != null) return Long.parseLong(cachedFund);
        Long totalFund = fundingMapper.getTotalFund();
        redisTemplate.opsForValue().set(TOTAL_FUND_KEY, totalFund.toString(), Duration.ofMinutes(10));
        return totalFund;
    }

    // Top 펀딩 리스트 조회
    @Transactional
    public List<GetFundingResponseDto> getTopFundingList(){
        List<Funding> fundingList = fundingMapper.getTopFundingList();
        if (fundingList == null) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }

    // 최신 펀딩 리스트 조회
    @Transactional
    public List<GetFundingResponseDto> getLatestFundingList(int page){
        List<Funding> fundingList = fundingMapper.getLatestFundingList((page - 1)  * 5);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }

    // 카테고리별 펀딩 리스트 조회
    @Transactional
    public List<GetFundingResponseDto> getCategoryFundingList(String category, int page){
        List<Funding> fundingList = fundingMapper.getCategoryFundingList(category, (page - 1)  * 5);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }

    // 레디스키 생성 메서드
    private String makeRedisKey(String sort, List<String> categories, int page){
        String categoryPart = (categories == null || categories.isEmpty())
                ? "전체"
                : String.join(",", categories);
        return String.format("funding::%s::%s::%d", sort, categoryPart, page);
    }

    // redis 캐싱 메서드
    private void redisCaching(String redisKey, List<?> dtoList) {
        // redis에 캐싱
        try {
            String json = objectMapper.writeValueAsString(dtoList);
            redisTemplate.opsForValue().set(redisKey, json, Duration.ofMinutes(1)); // TTL 설정
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }

    // 펀딩 페이지 조회
    @Transactional
    public List<GetFundingResponseDto> getFundingPageList(String sort, int page, List<String> categories){

        String redisKey = makeRedisKey(sort, categories, page);
        System.out.println(redisKey);

        // redis에서 키 조회
        String cachedJson = redisTemplate.opsForValue().get(redisKey);

        if (cachedJson != null) {
            try {
                return objectMapper.readValue(cachedJson, new TypeReference<>() {});
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            }
        }

        // redis에 없으면 DB 조회
        int offset = (page -1) * PAGE_SIZE;
        List<Funding> fundingList = fundingMapper.getFundingPageList(sort, categories, offset, PAGE_SIZE);
        List<GetFundingResponseDto> dtoList = fundingList.stream()
                .map(Funding::toDto).collect(Collectors.toList());

        // redis에 캐싱
        redisCaching(redisKey, dtoList);
        return dtoList;
    }

    // 펀딩 검색페이지 토픽 검색 (베스트 펀딩, 마감임박, 오늘의 검색어)
    @Transactional
    public List<FundingWishCountResponseDto> getSearchSpecialFunding(String sort , String topic, int page){

        if (!topic.equals("soon") && !topic.equals("best")) {
            throw new CustomException(BAD_REQUEST);
        }

        String redisKey = String.format("special::%s::%s::%d", sort, topic, page);
        System.out.println(redisKey);

        // redis에서 키 조회
        String cachedJson = redisTemplate.opsForValue().get(redisKey);

        if (cachedJson != null) {
            try {
                return objectMapper.readValue(cachedJson, new TypeReference<>() {});
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            }
        }

        // redis에 없으면 DB 조회
        int offset = (page -1) * PAGE_SIZE;

        List<FundingWishCount> fundingList = fundingMapper.getSpecialFundingList(topic, sort, offset, PAGE_SIZE);
        List<FundingWishCountResponseDto> dtoList = fundingList.stream()
                .map(FundingWishCount::toDto).collect(Collectors.toList());

        // redis에 캐싱
        redisCaching(redisKey, dtoList);
        return dtoList;
    }

    // 펀딩 키워드 검색 조회
//    @Transactional
//    public List<GetFundingResponseDto> getSearchFundingList(String sort, String keyword, int page) {
//
//        String redisKey = String.format("search::%s::%s::%d", sort, keyword, page);
//        System.out.println(redisKey);
//
//        // redis에서 키 조회
//        String cachedJson = redisTemplate.opsForValue().get(redisKey);
//
//        if (cachedJson != null) {
//            try {
//                return objectMapper.readValue(cachedJson, new TypeReference<>() {});
//            } catch (JsonProcessingException e) {
//                e.printStackTrace();
//            }
//        }
//
//        // redis에 없으면 DB 조회
//        int offset = (page -1) * PAGE_SIZE;
//        List<Funding> fundingList = fundingMapper.getSearchFundingList(sort, keyword, offset, PAGE_SIZE);
//        List<GetFundingResponseDto> dtoList = fundingList.stream()
//                .map(Funding::toDto).collect(Collectors.toList());
//
//        // redis에 캐싱
//        redisCaching(redisKey, dtoList);
//
//        return dtoList;
//    }

    @Transactional
    public List<GetFundingResponseDto> getSearchFundingList(String sort, String keyword, int page) {
        String redisKey = String.format("search::%s::%s::%d", sort, keyword, page);
        System.out.println("Redis Key: " + redisKey);
        String cachedJson = redisTemplate.opsForValue().get(redisKey);
        if (cachedJson != null) {
            try {
                return objectMapper.readValue(cachedJson, new TypeReference<List<GetFundingResponseDto>>() {});
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            }
        }
        List<FundingDocument> docList = elasticsearchService.searchDocuments(keyword, sort, page, PAGE_SIZE);
        List<GetFundingResponseDto> dtoList = docList.stream()
                .map(doc -> GetFundingResponseDto.builder()
                        .fundingId(doc.getFundingId())
                        .sellerId(doc.getSellerId())
                        .title(doc.getTitle())
                        .description(doc.getDescription())
                        .build())
                .collect(Collectors.toList());
        redisCaching(redisKey, dtoList);
        return dtoList;
    }

    // 펀딩 상세 페이지
    @Transactional
    public GetFundingResponseDto getFundingDetail(int fundingId) {
        Funding funding = fundingMapper.findById(fundingId);
        if (funding == null) {
            throw new CustomException(FUNDING_NOT_FOUND);
        }
        return funding.toDto();
    }


    // 브랜드 만족도 조회
    @Transactional
    public ReviewResponseDto getFundingReview(int sellerId, int page) {
        List<ReviewDto> reviewList = fundingMapper.getReviewList(sellerId, (page - 1) * 5); // 지금 페이지 네이션 x

        float totalRating = (float) reviewList.stream()
                .mapToDouble(review -> (double) review.getRating())
                .average()
                .orElse(0.0);

        //Builder를 사용하여 겍체 생성
        ReviewResponseDto response = ReviewResponseDto.builder()
                .totalRating(totalRating)
                .reviews(reviewList)
                .build();

        return response;
    }

    // 판매자 상세페이지 판매자 정보 요청 조회
    @Transactional
    public SellerDetailResponseDto getSellerDetail(int sellerId) {
        List<SellerDetail> sellerDetailList = fundingMapper.getSellerDetail(sellerId);
        List<SellerDetailDto> dtoList = sellerDetailList.stream()
                .map(SellerDetailDto::toDto)
                .collect(Collectors.toList());
        return SellerDetailResponseDto.from(dtoList);
    }

    // 내가 주훔한 펀딩 조회
    @Transactional
    public List<MyFundingResponseDto> getMyFunding(List<Integer> fundingIds){
        List<Funding> fundingList = fundingMapper.getMyFunding(fundingIds);
        log.info("fundingList: " + fundingList);
        return fundingList.stream()
                .map(MyFundingResponseDto::toDto).collect(Collectors.toList());
    }
    @Override
    public GetSellerTotalAmountResponseDto getSellerTotalAmount(int sellerId) {
        int totalAmount = fundingMapper.getSellerTotalAmount(sellerId);
        return GetSellerTotalAmountResponseDto
                .builder()
                .totalAmount(totalAmount)
                .build();
    }

    @Override
    public GetSellerTotalFundingCountResponseDto getSellerTotalFundingCount(int sellerId) {
        int totalCount = fundingMapper.getSellerTotalFundingCount(sellerId);
        return GetSellerTotalFundingCountResponseDto
                .builder()
                .totalCount(totalCount)
                .build();
    }

    @Override
    public GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(int sellerId) {
        List<Integer> fundingIdList = fundingMapper.getSellerTodayOrderCount(sellerId);

        if(fundingIdList.size() == 0) {
            int todayOrderCount = 0;
            return GetSellerTodayOrderCountResponseDto
                    .builder()
                    .todayOrderCount(todayOrderCount)
                    .build();
        }

        int todayOrderCount = orderClient.getSellerTodayOrderCount(
                GetSellerTodayOrderCountRequestDto
                        .builder()
                        .fundingIdList(fundingIdList)
                        .build()
        ).getTodayOrderCount();

        return GetSellerTodayOrderCountResponseDto
                .builder()
                .todayOrderCount(todayOrderCount)
                .build();
    }

    @Override
    public List<GetSellerOngoingTopFiveFundingResponseDto> getSellerOngoingTopFiveFunding(int sellerId) {
        List<Funding> fundingList = fundingMapper.getSellerOngoingTopFiveFunding(sellerId);
        return fundingList.stream().map(Funding::toGetSellerOngoingTopFiveFundingResponseDto).collect(Collectors.toList());
    }

    @Override
    public List<GetSellerOngoingFundingListResponseDto> getSellerOngoingFundingList(int sellerId, int page) {
        List<Funding> fundingList = fundingMapper.getSellerOngoingFundingList(sellerId, page);
        return fundingList.stream().map(Funding::toGetSellerOngoingFundingListResponseDto).collect(Collectors.toList());
    }

    @Override
    public List<Funding> getSuccessFundingsNotSent() {
        // SUCCESS 상태이며 아직 settlementCompleted가 false인 펀딩 조회
        return fundingMapper.findByStatusAndEventSent(false);
    }

    @Override
    public Funding getFundingById(int fundingId) {
        return fundingMapper.findById(fundingId);
    }

    @Override
    public void updateSettlementCompleted(int fundingId, Boolean eventSent) {
        fundingMapper.updateSettlementCompleted(fundingId, eventSent);
    }

    @Override
    public GetExpectedSettlementsResponseDto getExpectedSettlements(int sellerId) {
        GetExpectedSettlementsResponseDto result = GetExpectedSettlementsResponseDto
                .builder()
                .expectedAmount(fundingMapper.getExpectedSettlements(sellerId))
                .build();
        return result;
    }

    @Override
    public List<GetCompletedFundingsResponseDto> getCompletedFundings(int sellerId) {
        List<Funding> fundings = fundingMapper.getCompletedFundings(sellerId);
        List<GetCompletedFundingsResponseDto> dtos = new ArrayList<>();
        for(Funding f : fundings){
            GetCompletedFundingsResponseDto temp = GetCompletedFundingsResponseDto.builder()
                    .title(f.getTitle())
                    .endDate(f.getEndDate())
                    .totalAmount(f.getCurrentAmount())
                    .progressPercentage(f.getProgressPercentage())
                    .fundingId(f.getFundingId())
                    .build();
            dtos.add(temp);
        }
        return dtos;
    }

    @Override
    public List<GetSellerEndFundingListResponseDto> getSellerEndFundingList(int sellerId, int page) {
        List<Funding> fundingList = fundingMapper.getSellerEndFundingList(sellerId, page);
        return fundingList.stream().map(Funding::toGetSellerEndFundingListResponseDto).collect(Collectors.toList());
    }

    @Override
    public GetSellerFundingDetailResponseDto getSellerFundingDetail(int fundingId) {
        return fundingMapper.getSellerFundingDetail(fundingId).toGetSellerFundingDetailResponseDto();
    }

    @Override
    public List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(int sellerId) {
        List<Integer> fundingIdList = fundingMapper.getSellerTodayOrderCount(sellerId);
        System.out.println(fundingIdList);
        List<GetSellerMonthAmountStatisticsResponseDto> result = orderClient.getSellerMonthAmountStatistics(fundingIdList);
        return result;
    }

    @Override
    public List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(int fundingId) {
        return List.of();
    }

    @Override
    public List<GetSellerBrandStatisticsResponseDto> getSellerBrandStatistics(int sellerId) {
        List<GetSellerBrandStatisticsResponseDto> result = new ArrayList<>();
        List<Integer> fundingIdList = fundingMapper.getSellerTodayOrderCount(sellerId);
        List<Integer> userIdList = orderClient.getSellerBrandStatistics(fundingIdList);
        List<GetAgeListRequestDto> ageListRequestDtoList = userIdList.stream()
                .map(userIdTarget -> new GetAgeListRequestDto(userIdTarget))
                .collect(Collectors.toList());
        List<Integer> userStatistics = userClient.getAgeList(ageListRequestDtoList);

        int totalCount = 0;
        for(int count: userStatistics) {
            totalCount += count;
        }
        if(totalCount == 0) return result;

        for (int i = 0; i < userStatistics.size(); i++) {
            double percentage = (double) userStatistics.get(i) / totalCount * 100;
            result.add(new GetSellerBrandStatisticsResponseDto((i + 1) * 10, Math.round(percentage * 10) / 10.0));
        }

        return result;
    }

    @Override
    public List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThree(int sellerId) {
        List<Integer> fundingIdListRequestDto = fundingMapper.getSellerTodayOrderCount(sellerId);
        List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> orderList = orderClient.getSellerTodayOrderTopThree(fundingIdListRequestDto);
        if(orderList.isEmpty()) {
            return Collections.emptyList();
        }
        List<Integer> fundingIdList = orderList.stream().map(GetSellerTodayOrderTopThreeIdAndMoneyResponseDto::getFundingId).collect(Collectors.toList());
        List<Funding> fundingList = fundingMapper.getSellerTodayOrderTopThree(fundingIdList);
        List<GetSellerTodayOrderTopThreeListResponseDto> result = fundingList.stream().map(Funding::toGetSellerTodayOrderTopThreeListResponseDto).collect(Collectors.toList());
        for(int i = 0; i < orderList.size(); i++) {
            result.get(i).setTodayAmount(orderList.get(i).getTotalAmount());
        }
        return result;
    }

}
