package com.seller.service;


import com.seller.common.response.PageResponse;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.request.GrantSellerRoleRequestDto;
import com.seller.dto.response.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface SellerService {
    ResponseEntity<?> createFunding(int userId, FundingCreateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
    ResponseEntity<?> updateFunding(int fundingId, FundingUpdateRequestDto dto, MultipartFile storyFile, List<MultipartFile> imageFiles);
    ResponseEntity<?> deleteFunding(int fundingId);
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
    GetSellerFundingDetailResponseDto getSellerFundingDetail(int fundingId);
    List<GetSellerFundingDetailOrderListResponseDto> getSellerFundingDetailOrderList(int fundingId, int page);
    List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(int userId);
    List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(int fundingId);
    List<GetSellerBrandStatisticsResponseDto> getSellerBrandStatistics(int userId);
    List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThree(int userId);

    void processSettlement(int fundingId, int sellerId);

    PageResponse<GetCompletedFundingsResponseDto> getCompletedFundings(int userId, int page, int size);

}
