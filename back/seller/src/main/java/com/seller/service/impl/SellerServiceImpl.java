package com.seller.service.impl;

import com.seller.client.FundingClient;
import com.seller.client.OrderClient;
import com.seller.common.exception.CustomException;
import com.seller.common.response.ResponseCode;
import com.seller.common.util.JsonConverter;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingCreateSendDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.request.FundingUpdateSendDto;
import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.FundingResponseDto;
import com.seller.dto.response.OrderInfoResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import com.seller.dto.ssafyApi.response.ApiResponseDto;
import com.seller.entity.Seller;
import com.seller.mapper.SellerMapper;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.seller.common.response.ResponseCode.SELLER_NOT_FOUND;

@Slf4j
@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerMapper sellerMapper;
    private final FundingClient fundingClient;
    private final S3FileService s3FileService;
    private final OrderClient orderClient;
    private final SettlementApiService settlementApiService;

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

    @Override
    public Map<Integer, String> getNamesByIds(List<Integer> sellerIds) {
        List<Seller> sellers = sellerMapper.findNamesByIds(sellerIds);

        return sellers.stream()
                .collect(Collectors.toMap(
                        Seller::getSellerId,
                        Seller::getName,
                        (existing, replacement) -> existing
                ));
    }


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
    @Transactional
    public void processSettlement(int fundingId, int sellerId) {
        log.info("Processing settlement for fundingId: {}", fundingId);
        // Order 서비스 호출: 주문 총액 정보 조회
        OrderInfoResponseDto orderInfo = orderClient.getOrderInfoByFundingId(fundingId);
        if (orderInfo != null) {
            int totalAmount = orderInfo.getTotalAmount();
            ApiResponseDto response = settlementApiService.transferSettlement(totalAmount, sellerId);
            if (response == null || response.getHeader() == null ||
                    response.getHeader().getResponseCode() == null ||
                    !"H0000".equals(response.getHeader().getResponseCode())) {
                log.error("Settlement transfer failed for fundingId: {}", fundingId);
                throw new RuntimeException("Settlement transfer failed for fundingId: " + fundingId);
            }
            log.info("Settlement transfer succeeded for fundingId: {}, totalAmount: {}", fundingId, totalAmount);
            // 정산 이체 성공 시 Funding 서비스에 settlementCompleted 플래그 업데이트 요청
            fundingClient.updateSettlementCompleted(fundingId, true);
        } else {
            log.error("Order info not found for fundingId: {}", fundingId);
            throw new RuntimeException("Order info not found for fundingId: " + fundingId);
        }
    }
}
