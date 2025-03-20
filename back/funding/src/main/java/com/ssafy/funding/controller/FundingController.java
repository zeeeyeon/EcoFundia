package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/funding")
@RequiredArgsConstructor
public class FundingController {

    private final ProductService productService;

    @GetMapping("/{fundingId}")
    public ResponseEntity<?> getFunding(@PathVariable int fundingId) {
        FundingResponseDto funding = productService.getFunding(fundingId);
        return new ResponseEntity<>(Response.create(GET_FUNDING, funding), GET_FUNDING.getHttpStatus());
    }

    @PostMapping(value = "/{sellerId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createFunding(@PathVariable int sellerId,
                                           @RequestPart("dto") FundingCreateRequestDto dto,
                                           @RequestPart("storyFile") MultipartFile storyFile,
                                           @RequestPart("imageFiles") List<MultipartFile> imageFiles) {
        productService.createFunding(sellerId, dto, storyFile, imageFiles);
        return new ResponseEntity<>(Response.create(CREATE_FUNDING, null), CREATE_FUNDING.getHttpStatus());
    }

    @PatchMapping(value = "/{fundingId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateFunding(
            @PathVariable int fundingId,
            @RequestPart("dto") FundingUpdateRequestDto dto,
            @RequestPart(value = "storyFile", required = false) MultipartFile storyFile,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles
    ) {
        productService.updateFunding(fundingId, dto, storyFile, imageFiles);
        return new ResponseEntity<>(Response.create(UPDATE_FUNDING, null), UPDATE_FUNDING.getHttpStatus());
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteFunding(@PathVariable int fundingId) {
        productService.deleteFunding(fundingId);
        return new ResponseEntity<>(Response.create(DELETE_FUNDING, null), DELETE_FUNDING.getHttpStatus());
    }
}
