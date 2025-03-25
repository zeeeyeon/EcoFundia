package com.ssafy.funding.service.impl;

import com.ssafy.funding.client.SellerClient;
import com.ssafy.funding.common.exception.CustomException;
import com.ssafy.funding.common.response.ResponseCode;
import com.ssafy.funding.dto.funding.response.UserWishlistFundingDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.WishList;
import com.ssafy.funding.mapper.FundingMapper;
import com.ssafy.funding.mapper.WishListMapper;
import com.ssafy.funding.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WishListServiceImpl implements WishListService {

    private final WishListMapper wishListMapper;
    private final FundingMapper fundingMapper;
    private final SellerClient sellerClient;


    @Override
    public void createWish(int userId, int fundingId) {
        existsByUserIdAndFundingId(userId, fundingId);
        wishListMapper.createWish(WishList.createWish(userId, fundingId));
    }

    @Override
    public List<UserWishlistFundingDto> getOngoingWishlist(int userId) {
        List<WishList> wishList = wishListMapper.findOngoingByUserId(userId);
        return WishListDto(wishList);
    }

    @Override
    public List<UserWishlistFundingDto> getDoneWishlist(int userId) {
        List<WishList> wishList = wishListMapper.findDoneByUserId(userId);
        return WishListDto(wishList);
    }

    @Override
    public void deleteWish(int userId, int fundingId) {
        existsByUserIdAndFundingId(userId, fundingId);
        wishListMapper.deleteWish(userId, fundingId);
    }

    private void existsByUserIdAndFundingId(int userId, int fundingId) {
        if (wishListMapper.existsByUserIdAndFundingId(userId, fundingId)) throw new CustomException(ResponseCode.WISHLIST_ALREADY_EXISTS);
    }

    private List<UserWishlistFundingDto> WishListDto(List<WishList> wishList) {
        return wishList.stream()
                .map(wish -> {
                    Funding funding = fundingMapper.findById(wish.getFundingId());
                    String sellerName = sellerClient.getSellerName(funding.getSellerId());
                    return UserWishlistFundingDto.from(funding, sellerName);
                })
                .toList();
    }
}
