package com.ssafy.funding.client;

import com.ssafy.funding.dto.funding.request.FundingCreateRequestDto;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@FeignClient(name = "seller")
public interface SellerClient {

    @GetMapping("/api/seller/sellerName/{sellerId}")
    String getSellerName(@PathVariable("sellerId") int sellerId);


}