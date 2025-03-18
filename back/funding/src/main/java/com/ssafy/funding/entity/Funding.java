package com.ssafy.funding.entity;

import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Funding {
    private Integer fundingId;
    private Integer sellerId;
    private String title;
    private String description;
    private String storyFileUrl;
    private Integer price;
    private Integer quantity;
    private Integer targetAmount;
    private Integer currentAmount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;

    private Status status;
    private Category category;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
