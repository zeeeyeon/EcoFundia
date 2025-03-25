package com.ssafy.user.service.impl;

import com.ssafy.user.client.FundingClient;
import com.ssafy.user.entity.WishList;
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
        fundingClient.createWish(userId,fundingId);
    }

    @Override
    public List<WishList> getWishList(String userId) {
        return null;
    }

    @Override
    public void deleteWish(String userId, int fundingId) {
        fundingClient.deleteWish(userId,fundingId);
    }
}