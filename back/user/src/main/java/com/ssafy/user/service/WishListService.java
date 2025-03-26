package com.ssafy.user.service;

import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishiListResponseDto;

public interface WishListService {

    void createWish(int userId, int fundingId);

    PageResponse<WishiListResponseDto> getWishList(int userId, int page, int size);

    void deleteWish(int userId, int fundingId);

    PageResponse<WishiListResponseDto> getDoneWishList(int userId, int page, int size);
}
