package com.ssafy.user.service;

import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishiListResponseDto;

public interface WishListService {

    void createWish(String userId, int fundingId);

    PageResponse<WishiListResponseDto> getWishList(String userId, int page, int size);

    void deleteWish(String userId, int fundingId);

    PageResponse<WishiListResponseDto> getDoneWishList(String userId, int page, int size);
}
