package com.ssafy.funding.dto.seller;

import com.ssafy.funding.entity.enums.Status;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class SellerDetailDto {

    private int fundingId;
    private String title;
    private String description;
    private List<String> imageUrls;
    private int price;
    private int targetAmount;
    private int currentAmount;
    private LocalDateTime endDate;
    private Status status;

    private int totalRating; // rating
    private int ratingCount; // 만족도에 사용된 rating 개수

    private int wishlistCount; // 찜 개수
}
