package com.ssafy.funding.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateSendDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.FundingWishCountResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.funding.response.MyFundingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.FundingWishCount;
import com.ssafy.funding.entity.enums.Status;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Duration;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import static com.ssafy.funding.common.response.ResponseCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class FundingService implements ProductService {

    private final FundingMapper fundingMapper;
    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    private static final int PAGE_SIZE = 5;

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
        return funding;
    }

    @Override
    @Transactional
    public Funding updateFunding(int fundingId, FundingUpdateSendDto dto) {
        Funding funding = findByFundingId(fundingId);
        funding.update(dto);
        fundingMapper.updateFunding(funding);
        return funding;
    }

    @Override
    public void deleteFunding(int fundingId) {
        findByFundingId(fundingId);
        fundingMapper.deleteFunding(fundingId);
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
        Long totalFund = fundingMapper.getTotalFund();
        return totalFund;
    }

    // Top 펀딩 리스트 조회
    @Transactional
    public List<GetFundingResponseDto> getTopFundingList(){
        List<Funding> fundingList = fundingMapper.getTopFundingList();
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
    @Transactional
    public List<GetFundingResponseDto> getSearchFundingList(String sort, String keyword, int page) {

        String redisKey = String.format("search::%s::%s::%d", sort, keyword, page);
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
        List<Funding> fundingList = fundingMapper.getSearchFundingList(sort, keyword, offset, PAGE_SIZE);
        List<GetFundingResponseDto> dtoList = fundingList.stream()
                .map(Funding::toDto).collect(Collectors.toList());

        // redis에 캐싱
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
        List<SellerDetailDto> sellerDetailList = fundingMapper.getSellerDetail(sellerId);
        return SellerDetailResponseDto.from(sellerDetailList);
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

}
