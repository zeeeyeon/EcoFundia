package com.ssafy.user.service.impl;

import com.ssafy.user.client.FundingClient;
import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishiListResponseDto;
import com.ssafy.user.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WishListServiceImpl implements WishListService {

    private final FundingClient fundingClient;

    @Override
    public void createWish(String userId, int fundingId) {
        fundingClient.createWish(userId, fundingId);
    }

    @Override
    public PageResponse<WishiListResponseDto> getWishList(String userId, int page, int size) {
        List<WishiListResponseDto> all = fundingClient.getMyWishList(userId);
        return paginate(all, page, size);
    }

    @Override
    public void deleteWish(String userId, int fundingId) {
        fundingClient.deleteWish(userId, fundingId);
    }

    @Override
    public PageResponse<WishiListResponseDto> getDoneWishList(String userId, int page, int size) {
        List<WishiListResponseDto> all = fundingClient.getDoneMyWishList(userId);
        return paginate(all, page, size);
    }

    private PageResponse<WishiListResponseDto> paginate(List<WishiListResponseDto> list, int page, int size) {
        int total = list.size();
        int start = Math.min(page * size, total);
        int end = Math.min(start + size, total);

        List<WishiListResponseDto> content = list.subList(start, end);
        int totalPages = (int) Math.ceil((double) total / size);

        return new PageResponse<>(content, page, size, total, totalPages);
    }
}
