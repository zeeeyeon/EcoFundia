package com.seller.mapper;

import com.seller.dto.response.FundingDetailSellerResponseDto;
import com.seller.entity.Seller;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SellerMapper {

    boolean findByUserId(int userId);
    List<Seller> findByIds(@Param("sellerIds") List<Integer> sellerIds);
    FundingDetailSellerResponseDto sellerInfo(int sellerId);

    //판매자 조회
    Seller getSeller(int sellerId);
}
