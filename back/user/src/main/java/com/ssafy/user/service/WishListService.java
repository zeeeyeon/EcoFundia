package com.ssafy.user.service;

import com.ssafy.user.entity.WishList;

import java.util.List;

public interface WishListService {
    void createWish(String userId, int fundingId);
    List<WishList> getWishList(String userId);
    void deleteWish(String userId, int fundingId);
    List<WishList> getDoneWishList(String userId);
}

