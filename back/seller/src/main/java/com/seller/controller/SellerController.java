package com.seller.controller;

import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;
import com.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/seller")
@RequiredArgsConstructor
public class SellerController {

    private final SellerService sellerService;


    @GetMapping("/{fundingId}")
    ResponseEntity<?> getFunding(@PathVariable int fundingId) {
        return null;
    }

    @PostMapping(value = "api/funding/{sellerId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<?> createFunding(@PathVariable int sellerId,
                                    @RequestPart("dto") FundingCreateRequestDto dto,
                                    @RequestPart("storyFile") MultipartFile storyFile,
                                    @RequestPart("imageFiles") List<MultipartFile> imageFiles) {
        return null;
    }

    @PatchMapping(value = "/{fundingId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<?> updateFunding(
            @PathVariable int fundingId,
            @RequestPart("dto") FundingUpdateRequestDto dto,
            @RequestPart(value = "storyFile", required = false) MultipartFile storyFile,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {
        return null;
    }

    @DeleteMapping("/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable int fundingId) {
        return null;
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
