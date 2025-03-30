package com.seller.service;


import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface SellerService {
//    ResponseEntity<?> getFundingId(int fundingId);
//    ResponseEntity<?> createFunding(int sellerId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
//    ResponseEntity<?> updateFunding(int fundingId, FundingUpdateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
//    ResponseEntity<?> deleteFunding(int fundingId);
    Boolean findByUserId(int userId);
    Map<Integer, String> getNamesByIds(List<Integer> sellerIds);

    FundingDetailSellerResponseDto sellerInfo(int sellerId);

    SellerAccountResponseDto getSellerAccount(int sellerId);

    void processSettlement(int fundingId);
}
