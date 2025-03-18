package com.ssafy.funding.entity;

import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.Builder;
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

    @Builder
    public Funding(int sellerId, String title, String description, String storyFileUrl, int price, int quantity, int targetAmount, LocalDateTime startDate, LocalDateTime endDate, Category category) {
        this.sellerId = sellerId;
        this.title = title;
        this.description = description;
        this.storyFileUrl = storyFileUrl;
        this.price = price;
        this.quantity = quantity;
        this.targetAmount = targetAmount;
        this.currentAmount = 0;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = Status.ONGOING;
        this.category = category;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}
