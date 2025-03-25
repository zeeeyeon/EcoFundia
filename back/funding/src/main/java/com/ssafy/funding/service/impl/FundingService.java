package com.ssafy.funding.service.impl;

import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.response.ResponseCode;
import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingCreateSendDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.response.FundingResponseDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.dto.review.response.ReviewResponseDto;
import com.ssafy.funding.dto.seller.SellerDetailDto;
import com.ssafy.funding.dto.seller.SellerDetailResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Status;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FundingService implements ProductService {

    private final FundingMapper fundingMapper;
    private final S3FileService s3FileService;

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
    public Funding updateFunding(int fundingId, FundingUpdateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles) {
        Funding funding = findByFundingId(fundingId);

        String oldStoryFileUrl = funding.getStoryFileUrl();
        List<String> oldImageUrls = funding.getImageUrlList();

        String newStoryFileUrl = s3FileService.uploadFile(storyFile, "funding/story");
        List<String> newImageUrls = s3FileService.uploadFiles(imageFiles, "funding/images");

        funding.update(dto, newStoryFileUrl, newImageUrls);
        fundingMapper.updateFunding(funding);

        if (newStoryFileUrl != null && !newStoryFileUrl.equals(oldStoryFileUrl)) s3FileService.deleteFile(oldStoryFileUrl);
        if (!newImageUrls.isEmpty() && !newImageUrls.equals(oldImageUrls)) s3FileService.deleteFiles(oldImageUrls);

        return funding;
    }

    @Override
    public void deleteFunding(int fundingId) {
        findByFundingId(fundingId);
        fundingMapper.deleteFunding(fundingId);
    }

    private Funding findByFundingId(int fundingId) {
        Funding funding = fundingMapper.findById(fundingId);
        if (funding == null) throw new CustomException(ResponseCode.FUNDING_NOT_FOUND);
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
        return fundingMapper.getTotalFund();
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

    // 펀딩 키워드 검색 조회
    @Transactional
    public List<GetFundingResponseDto> getSearchFundingList(String keyword, int page) {
        List<Funding> fundingList = fundingMapper.getSearchFunding(keyword, (page - 1)  * 5);
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());
    }

    // 펀딩 상세 페이지
    @Transactional
    public GetFundingResponseDto getFundingDetail(int fundingId) {
        Funding funding = fundingMapper.findById(fundingId);
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
}
