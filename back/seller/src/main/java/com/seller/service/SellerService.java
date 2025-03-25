package com.seller.service;

import com.seller.dto.FundingDetailSellerResponseDto;
import com.seller.dto.response.SellerAccountResponseDto;

public interface SellerService {

    FundingDetailSellerResponseDto sellerInfo(int sellerId);

    SellerAccountResponseDto getSellerAccount(int sellerId);
}
