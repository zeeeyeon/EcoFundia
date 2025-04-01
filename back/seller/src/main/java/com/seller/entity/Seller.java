package com.seller.entity;

import lombok.Data;

@Data
public class Seller {

    private int sellerId;
    private int userId;
    private String profileImg;
    private String account;
    private String ssafyUserKey;
    private String name;
    private String businessNumber;
}
