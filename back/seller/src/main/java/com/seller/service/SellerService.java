package com.seller.service;

import com.seller.dto.FundingDetailSellerResponseDto;

public interface SellerService {

    FundingDetailSellerResponseDto sellerInfo(int sellerId);
}
