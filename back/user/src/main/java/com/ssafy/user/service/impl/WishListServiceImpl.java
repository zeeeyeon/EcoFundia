package com.ssafy.user.service.impl;

import com.ssafy.user.common.exception.CustomException;
import com.ssafy.user.common.response.ResponseCode;
import com.ssafy.user.entity.WishList;
import com.ssafy.user.mapper.WishListMapper;
import com.ssafy.user.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WishListServiceImpl implements WishListService {

    private final WishListMapper wishListMapper;

    @Override
    public void createWish(int userId, int fundingId) {
        if (wishListMapper.existsByUserIdAndFundingId(userId, fundingId)) throw new CustomException(ResponseCode.WISHLIST_ALREADY_EXISTS);
        wishListMapper.createWish(WishList.createWish(userId, fundingId));
    }

    @Override
    public List<WishList> getWishList(int userId) {
        return wishListMapper.findByUserId(userId);
    }

    @Override
    public void deleteWish(int userId, int fundingId) {
        wishListMapper.deleteWish(userId, fundingId);
    }
}