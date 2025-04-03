package com.ssafy.funding.service;

import com.ssafy.funding.dto.funding.response.UserWishlistFundingDto;

import java.util.List;

public interface WishListService {
    void createWish(int userId, int fundingId);
    List<UserWishlistFundingDto> getOngoingWishlist(int userId);
    List<UserWishlistFundingDto> getDoneWishlist(int userId);
    void deleteWish(int userId, int fundingId);
    List<Integer> getUserWishlist(int userId);
}
