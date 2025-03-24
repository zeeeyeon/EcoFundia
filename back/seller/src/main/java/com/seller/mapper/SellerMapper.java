package com.seller.mapper;

import com.seller.dto.FundingDetailSellerResponseDto;
import com.seller.entity.Seller;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SellerMapper {

    FundingDetailSellerResponseDto sellerInfo(int sellerId);

    //판매자 조회
    Seller getSeller(int sellerId);
}
