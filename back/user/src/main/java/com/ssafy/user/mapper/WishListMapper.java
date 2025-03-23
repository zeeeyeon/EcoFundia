package com.ssafy.user.mapper;

import com.ssafy.user.entity.WishList;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface WishListMapper {
    void createWish(WishList wishList);
    List<WishList> findByUserId(int userId);
    void deleteWish(int userId, int fundingId);
    boolean existsByUserIdAndFundingId(int userId, int fundingId);
}
