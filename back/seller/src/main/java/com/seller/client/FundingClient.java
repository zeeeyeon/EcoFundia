package com.seller.client;

import com.seller.config.FeignMultipartSupportConfig;
import com.seller.dto.request.FundingCreateRequestDto;
import com.seller.dto.request.FundingUpdateRequestDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@FeignClient(name = "funding", configuration = FeignMultipartSupportConfig.class)
public interface FundingClient {

    @GetMapping("api/funding/{fundingId}")
    ResponseEntity<?> getFunding(@PathVariable int fundingId);

    @PostMapping(value = "api/funding/{sellerId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<?> createFunding(@PathVariable int sellerId,
                                           @RequestPart("dto") FundingCreateRequestDto dto,
                                           @RequestPart("storyFile") MultipartFile storyFile,
                                           @RequestPart("imageFiles") List<MultipartFile> imageFiles);

    @PatchMapping(value = "api/funding/{fundingId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<?> updateFunding(
            @PathVariable int fundingId,
            @RequestPart("dto") FundingUpdateRequestDto dto,
            @RequestPart(value = "storyFile", required = false) MultipartFile storyFile,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles);

    @DeleteMapping("api/funding/{fundingId}")
    ResponseEntity<?> deleteFunding(@PathVariable int fundingId);
}
