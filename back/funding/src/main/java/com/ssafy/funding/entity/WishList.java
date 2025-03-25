package com.ssafy.funding.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class WishList {
    private int wishlistId;
    private int userId;
    private int fundingId;

    private WishList(int userId, int fundingId) {
        this.userId = userId;
        this.fundingId = fundingId;
    }

    public static WishList createWish(int userId, int fundingId) {
        return new WishList(userId, fundingId);
    }
}
