package com.ssafy.user.service;

import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishListResponseDto;

import java.util.List;

public interface WishListService {

    void createWish(int userId, int fundingId);

    PageResponse<WishListResponseDto> getWishList(int userId, int page, int size);

    void deleteWish(int userId, int fundingId);

    PageResponse<WishListResponseDto> getDoneWishList(int userId, int page, int size);

    List<Integer> getWishListFundingIds(int userId);
}
