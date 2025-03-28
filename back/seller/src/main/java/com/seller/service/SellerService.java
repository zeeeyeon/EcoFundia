package com.seller.service;


import com.seller.dto.request.GrantSellerRoleRequestDto;
import com.seller.dto.response.*;

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

    void grantSellerRole(int userId, GrantSellerRoleRequestDto grantSellerRoleRequestDto);
    GetSellerTotalAmountResponseDto getSellerTotalAmount(int userId);
    GetSellerTotalFundingCountResponseDto getSellerTotalFundingCount(int userId);
    GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(int userId);
    List<GetSellerOngoingTopFiveFundingResponseDto> getSellerOngoingTopFiveFunding(int userId);
    List<GetSellerOngoingFundingListResponseDto> getSellerOngoingFundingList(int userId, int page);
    List<GetSellerEndFundingListResponseDto> getSellerEndFundingList(int userId, int page);
    List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThreeList(int userId);
}
