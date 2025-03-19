package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.response.FundingResponseDto;
import com.ssafy.funding.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.ssafy.funding.common.response.ResponseCode.CREATE_FUNDING;
import static com.ssafy.funding.common.response.ResponseCode.GET_FUNDING;

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

    @PostMapping("/{sellerId}")
    public ResponseEntity<?> createFunding(@PathVariable int sellerId, @RequestBody FundingCreateRequestDto dto) {
        productService.createFunding(sellerId, dto);
        return new ResponseEntity<>(Response.create(CREATE_FUNDING, null), CREATE_FUNDING.getHttpStatus());
    }

    @PutMapping("/{sellerId}")
    public ResponseEntity<?> updateFunding(@PathVariable Integer sellerId, @RequestBody FundingCreateRequestDto dto) {
        return null;
    }

}
