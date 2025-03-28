package com.seller.service.impl;

import com.seller.client.FundingClient;
import com.seller.dto.request.*;
import com.seller.dto.response.*;
import com.seller.entity.Seller;
import com.seller.mapper.SellerMapper;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerMapper sellerMapper;
    private final FundingClient fundingClient;
    private final S3FileService s3FileService;

//    @Override
//    public ResponseEntity<?> getFundingId(int fundingId) {
//        return fundingClient.getFundingId(fundingId);
//    }
//
//    @Override
//    public ResponseEntity<?> createFunding(int sellerId, FundingCreateRequestDto dto,
//                                           MultipartFile storyFile, List<MultipartFile> imageFiles) {
//        String storyFileUrl = s3FileService.uploadFile(storyFile, "funding/story");
//        List<String> imageUrls = s3FileService.uploadFiles(imageFiles, "funding/images");
//
//        String imageUrlsJson = JsonConverter.convertImageUrlsToJson(imageUrls);
//
//        FundingCreateSendDto toDto = dto.toDto(storyFileUrl, imageUrlsJson);
//
//        return fundingClient.createFunding(sellerId, toDto);
//    }
//
//    @Override
//    public ResponseEntity<?> updateFunding(int fundingId, FundingUpdateRequestDto dto,
//                                           MultipartFile storyFile, List<MultipartFile> imageFiles) {
//
//        String newStoryFileUrl = s3FileService.uploadFile(storyFile, "funding/story");
//        List<String> newImageUrls = s3FileService.uploadFiles(imageFiles, "funding/images");
//
//        FundingResponseDto oldFunding = fundingClient.getFundingById(fundingId);
//        String oldStoryFileUrl = oldFunding.storyFileUrl();
//        List<String> oldImageUrls = oldFunding.imageUrlList();
//
//        if (newStoryFileUrl != null && !newStoryFileUrl.equals(oldStoryFileUrl)) s3FileService.deleteFile(oldStoryFileUrl);
//        if (!newImageUrls.isEmpty() && !newImageUrls.equals(oldImageUrls)) s3FileService.deleteFiles(oldImageUrls);
//
//        String imageUrlsJson = JsonConverter.convertImageUrlsToJson(newImageUrls);
//        FundingUpdateSendDto updateDto = dto.toDto(newStoryFileUrl, imageUrlsJson);
//
//        return fundingClient.updateFunding(fundingId, updateDto);
//    }
//
//    @Override
//    public ResponseEntity<?> deleteFunding(int fundingId) {
//        return fundingClient.deleteFunding(fundingId);
//    }

    @Override
    public Boolean findByUserId(int userId) {
        return sellerMapper.findByUserId(userId);
    }

//    @Override
//    public Map<Integer, String> getSellerNamesByIds(List<Integer> sellerIds) {
//        return sellerMapper.findByIds(sellerIds).stream()
//                .collect(Collectors.toMap(Seller::getSellerId, Seller::getName));
//    }

    // 펀딩 상세페이지 seller 정보 조회
    @Transactional
    public FundingDetailSellerResponseDto sellerInfo(int sellerId) {
        FundingDetailSellerResponseDto sellerInfo = sellerMapper.sellerInfo(sellerId);
        return sellerInfo;
    }

    // 판매자 계좌 번호 조회
    @Transactional
    public SellerAccountResponseDto getSellerAccount(int sellerId){
        Seller seller = sellerMapper.getSeller(sellerId);

        if (seller == null){
            return SellerAccountResponseDto.of("0","0");
        }
        return SellerAccountResponseDto.of(seller.getAccount(), seller.getSsafyUserKey());
    }

    @Override
    public void grantSellerRole(int userId, GrantSellerRoleRequestDto grantSellerRoleRequestDto) {
        String name = grantSellerRoleRequestDto.getName();
        String businessNumber = grantSellerRoleRequestDto.getBusinessNumber();
        sellerMapper.grantSellerRole(userId, name, businessNumber);
    }

    @Override
    public GetSellerTotalAmountResponseDto getSellerTotalAmount(int userId) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return GetSellerTotalAmountResponseDto
                .builder()
                .totalAmount(fundingClient.getSellerTotalAmount(sellerId).getTotalAmount())
                .build();
    }

    @Override
    public GetSellerTotalFundingCountResponseDto getSellerTotalFundingCount(int userId) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return GetSellerTotalFundingCountResponseDto
                .builder()
                .totalCount(fundingClient.getSellerTotalFundingCountResponseDto(sellerId).getTotalCount())
                .build();
    }

    @Override
    public GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(int userId) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return GetSellerTodayOrderCountResponseDto
                .builder()
                .todayOrderCount(fundingClient.getSellerTodayOrderCount(sellerId).getTodayOrderCount())
                .build();
    }

    @Override
    public List<GetSellerOngoingTopFiveFundingResponseDto> getSellerOngoingTopFiveFunding(int userId) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return fundingClient.getSellerOngoingTopFiveFunding(sellerId);
    }

    @Override
    public List<GetSellerOngoingFundingListResponseDto> getSellerOngoingFundingList(int userId, int page) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return fundingClient.getSellerOngoingFundingList(sellerId, page);
    }

    @Override
    public List<GetSellerEndFundingListResponseDto> getSellerEndFundingList(int userId, int page) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return fundingClient.getSellerEndFundingList(sellerId, page);
    }

    @Override
    public List<GetSellerTodayOrderTopThreeListResponseDto> getSellerTodayOrderTopThreeList(int userId) {
        int sellerId = sellerMapper.getSellerIdByUserId(userId);
        return fundingClient.getSellerTodayOrderTopThreeList(sellerId);
    }
}
