package com.seller.service;

import com.seller.dto.response.FundingDetailSellerResponseDto;

public interface SellerService {

    FundingDetailSellerResponseDto sellerInfo(int sellerId);
}
