package com.ssafy.funding.service.impl;

import com.ssafy.funding.client.FundingClient;
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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WishListServiceImpl implements WishListService {

    private final WishListMapper wishListMapper;
    private final FundingMapper fundingMapper;
    private final SellerClient sellerClient;

    @Override
    public void createWish(int userId, int fundingId) {
        validateWishNotExists(userId, fundingId);
        wishListMapper.createWish(WishList.createWish(userId, fundingId));
    }

    @Override
    public List<UserWishlistFundingDto> getOngoingWishlist(int userId) {
        List<WishList> wishList = wishListMapper.findOngoingByUserId(userId);
        return toWishlistDto(wishList);
    }

    @Override
    public List<UserWishlistFundingDto> getDoneWishlist(int userId) {
        List<WishList> wishList = wishListMapper.findDoneByUserId(userId);
        return toWishlistDto(wishList);
    }

    @Override
    public void deleteWish(int userId, int fundingId) {
        validateWishNotExists(userId, fundingId);
        wishListMapper.deleteWish(userId, fundingId);
    }

    private void validateWishNotExists(int userId, int fundingId) {
        if (wishListMapper.existsByUserIdAndFundingId(userId, fundingId)) {
            throw new CustomException(ResponseCode.WISHLIST_ALREADY_EXISTS);
        }
    }

    private List<UserWishlistFundingDto> toWishlistDto(List<WishList> wishList) {
        if (wishList.isEmpty()) return Collections.emptyList();

        List<Integer> fundingIds = wishList.stream()
                .map(WishList::getFundingId)
                .toList();

        List<Funding> fundings = fundingMapper.findFundingsByIds(fundingIds); // MyBatis

        List<Integer> sellerIds = fundings.stream()
                .map(Funding::getSellerId)
                .distinct()
                .toList();

        Map<Integer, String> sellerNameMap = sellerClient.getSellerNames(sellerIds);

        return fundings.stream()
                .map(f -> UserWishlistFundingDto.from(f, sellerNameMap.get(f.getSellerId())))
                .toList();
    }
}
