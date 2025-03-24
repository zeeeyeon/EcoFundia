package com.ssafy.funding.service;

import com.ssafy.funding.dto.funding.response.UserWishlistFundingDto;

import java.util.List;

public interface WishListService {
    void createWish(int userId, int fundingId);
    List<UserWishlistFundingDto> getWishList(int userId);
    void deleteWish(int userId, int fundingId);
}
