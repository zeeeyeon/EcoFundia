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
    private final S3FileUploader s3FileUploader;

    @Override
    @Transactional
    public Funding createFunding(int sellerId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles) {
        String storyFileUrl = s3FileUploader.uploadFile(storyFile, "funding/story");
        List<String> imageUrls = s3FileUploader.uploadFiles(imageFiles, "funding/images");

        String imageUrlsJson = JsonConverter.convertImageUrlsToJson(imageUrls);

        Funding funding = dto.toEntity(sellerId, storyFileUrl, imageUrlsJson);
        fundingMapper.createFunding(funding);

        return funding;
    }

    @Override
    public FundingResponseDto getFunding(int fundingId) {
        Funding funding = findByFundingId(fundingId);

        return FundingResponseDto.fromEntity(funding);
    }

    @Override
    @Transactional
    public Funding updateFunding(int fundingId, FundingUpdateRequestDto dto) {
        Funding funding = findByFundingId(fundingId);

        funding.applyUpdate(dto);
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
        if (funding == null) throw new CustomException(ResponseCode.FUNDING_NOT_FOUND);
        return funding;
    }
}
