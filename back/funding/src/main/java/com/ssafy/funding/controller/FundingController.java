package com.ssafy.funding.controller;

import com.ssafy.funding.dto.request.FundingCreateRequestDto;
import com.ssafy.funding.service.ProductService;
import com.ssafy.funding.service.impl.FundingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/funding")
@RequiredArgsConstructor
public class FundingController {
    private final ProductService productService;

    @PostMapping("/{sellerId}/create")
    public ResponseEntity<?> createFunding(@PathVariable Integer sellerId, @RequestBody FundingCreateRequestDto dto) {
        productService.createFunding(sellerId, dto);
        return ResponseEntity.ok("펀딩 생성");
    }
}
