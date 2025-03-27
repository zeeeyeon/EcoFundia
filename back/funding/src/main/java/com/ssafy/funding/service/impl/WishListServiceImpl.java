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
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

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
    @Transactional
    public List<UserWishlistFundingDto> getOngoingWishlist(int userId) {
        List<Integer> fundingIds = wishListMapper.findFundingIdsByUserId(userId);
        List<Funding> fundings = fundingMapper.findFundingsByIds(fundingIds);
        List<Funding> ongoingFundings = filterOngoing(fundings);
        Map<Integer, String> sellerNames = getSellerNames(ongoingFundings);

        return convertToDtos(ongoingFundings, sellerNames);
    }

    @Override
    public List<UserWishlistFundingDto> getDoneWishlist(int userId) {
        return List.of();
    }

    @Override
    public void deleteWish(int userId, int fundingId) {
        validateWishNotExists(userId, fundingId);
        wishListMapper.deleteWish(userId, fundingId);
    }

    public List<Integer> getWishlistFundingIds(int userId) {
        return wishListMapper.findFundingIdsByUserId(userId);
    }

    private void validateWishNotExists(int userId, int fundingId) {
        if (wishListMapper.existsByUserIdAndFundingId(userId, fundingId)) {
            throw new CustomException(ResponseCode.WISHLIST_ALREADY_EXISTS);
        }
    }

    private List<Funding> filterOngoing(List<Funding> fundings) {
        return fundings.stream()
                .filter(funding -> funding.getEndDate().isAfter(LocalDateTime.now()))
                .collect(Collectors.toList());
    }

    private Map<Integer, String> getSellerNames(List<Funding> fundings) {
        Set<Integer> sellerIds = fundings.stream()
                .map(Funding::getSellerId)
                .collect(Collectors.toSet());

        return sellerClient.getSellerNames(new ArrayList<>(sellerIds));
    }

    private List<UserWishlistFundingDto> convertToDtos(List<Funding> fundings, Map<Integer, String> sellerNames) {
        return fundings.stream()
                .map(funding -> UserWishlistFundingDto.from(funding, sellerNames.get(funding.getSellerId())))
                .collect(Collectors.toList());
    }
}
