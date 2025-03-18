package com.ssafy.funding.entity;

import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Funding {
    private int fundingId;
    private int sellerId;
    private String title;
    private String description;
    private String storyFileUrl;
    private int price;
    private int quantity;
    private int targetAmount;
    private int currentAmount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;

    private Status status;
    private Category category;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
