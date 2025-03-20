package com.ssafy.funding.service;

import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.entity.Funding;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ProductService {
    Funding createFunding(int sellerId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
    FundingResponseDto getFunding(int fundingId);
    Funding updateFunding(int fundingId, FundingUpdateRequestDto dto);
    void deleteFunding(int fundingId);
}
