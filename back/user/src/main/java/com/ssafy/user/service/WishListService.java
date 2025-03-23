package com.ssafy.user.service;

import com.ssafy.user.entity.WishList;

import java.util.List;

public interface WishListService {
    void createWish(int userId, int fundingId);
    List<WishList> getWishList(int userId);
    void deleteWish(int userId, int fundingId);
}

