package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.WishList;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface WishListMapper {
    void createWish(WishList wishList);
    List<WishList> findOngoingByUserId(int userId);
    List<WishList> findDoneByUserId(int userId);
    void deleteWish(int userId, int fundingId);
    boolean existsByUserIdAndFundingId(int userId, int fundingId);
    List<Integer> findFundingIdsByUserId(int userId);
}
