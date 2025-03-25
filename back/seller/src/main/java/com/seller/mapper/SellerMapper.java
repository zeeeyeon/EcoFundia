package com.seller.mapper;

import com.seller.dto.response.FundingDetailSellerResponseDto;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SellerMapper {

    FundingDetailSellerResponseDto sellerInfo(int sellerId);
}
