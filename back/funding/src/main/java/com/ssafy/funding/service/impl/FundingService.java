package com.ssafy.funding.service.impl;

import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.response.ResponseCode;
import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

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
    public Funding createFunding(int sellerId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles) {
        String storyFileUrl = s3FileService.uploadFile(storyFile, "funding/story");
        List<String> imageUrls = s3FileService.uploadFiles(imageFiles, "funding/images");

        String imageUrlsJson = JsonConverter.convertImageUrlsToJson(imageUrls);

        Funding funding = dto.toEntity(sellerId, storyFileUrl, imageUrlsJson);
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
}
