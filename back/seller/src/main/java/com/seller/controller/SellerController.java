package com.seller.controller;

import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/seller")
@RequiredArgsConstructor
public class SellerController {

    private final SellerService sellerService;

    @PostMapping(value = "/funding/{sellerId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createFunding(
            @PathVariable int sellerId,
            @RequestPart("dto") FundingCreateRequestDto dto,
            @RequestPart("storyFile") MultipartFile storyFile,
            @RequestPart("imageFiles") List<MultipartFile> imageFiles) {
        return sellerService.createFunding(sellerId, dto, storyFile, imageFiles);
    }

    @PutMapping(value = "/funding/{fundingId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateFunding(
            @PathVariable int fundingId,
            @RequestPart("dto") FundingUpdateRequestDto dto,
            @RequestPart(value = "storyFile", required = false) MultipartFile storyFile,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {
        return sellerService.updateFunding(fundingId, dto, storyFile, imageFiles);
    }

    @DeleteMapping("/funding/{fundingId}")
    public ResponseEntity<?> deleteFunding(@PathVariable int fundingId) {
        return sellerService.deleteFunding(fundingId);
    }

    @GetMapping("/check")
    public Boolean findByUserId(@RequestHeader("X-User-Id") int userId) {
        return sellerService.findByUserId(userId);
    }

    @PostMapping("/seller-names")
    public Map<Integer, String> getSellerNames(@RequestBody List<Integer> sellerIds) {
        log.info("getSellerNames: {}", sellerIds);
        return sellerService.getNamesByIds(sellerIds);
    }


    // 펀딩 상세페이지에 필요한 판매자 데이터 요청
    @GetMapping("/info/funding-page/{sellerId}")
    FundingDetailSellerResponseDto sellerInfo(@PathVariable int sellerId){
        FundingDetailSellerResponseDto sellerInfo = sellerService.sellerInfo(sellerId);
        return sellerInfo;
    }

    // 판매자 상세 정보 요청 조회
    @GetMapping("/detail/{sellerID}")
    String sellerDetail(@PathVariable int sellerId){
        return null;
    }

    // 판매자 계좌 번호 조회
    @GetMapping("api/seller/find/account")
    SellerAccountResponseDto getSellerAccount(@RequestParam(name = "sellerId") int sellerId){
        SellerAccountResponseDto sellerAccountResponseDto = sellerService.getSellerAccount(sellerId);
        return sellerAccountResponseDto;
    }
}
