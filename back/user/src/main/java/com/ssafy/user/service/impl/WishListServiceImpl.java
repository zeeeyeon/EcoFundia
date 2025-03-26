package com.ssafy.user.service.impl;

import com.ssafy.user.client.FundingClient;
import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishListResponseDto;
import com.ssafy.user.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WishListServiceImpl implements WishListService {

    private final FundingClient fundingClient;

    @Override
    public void createWish(int userId, int fundingId) {
        fundingClient.createWish(userId, fundingId);
    }

    @Override
    public PageResponse<WishListResponseDto> getWishList(int userId, int page, int size) {
        List<WishListResponseDto> all = fundingClient.getMyWishList(userId);
        return paginate(all, page, size);
    }

    @Override
    public void deleteWish(int userId, int fundingId) {
        fundingClient.deleteWish(userId, fundingId);
    }

    @Override
    public PageResponse<WishListResponseDto> getDoneWishList(int userId, int page, int size) {
        List<WishListResponseDto> all = fundingClient.getDoneMyWishList(userId);
        return paginate(all, page, size);
    }

    private PageResponse<WishListResponseDto> paginate(List<WishListResponseDto> list, int page, int size) {
        int total = list.size();
        int start = Math.min(page * size, total);
        int end = Math.min(start + size, total);

        List<WishListResponseDto> content = list.subList(start, end);
        int totalPages = (int) Math.ceil((double) total / size);

        return new PageResponse<>(content, page, size, total, totalPages);
    }
}
