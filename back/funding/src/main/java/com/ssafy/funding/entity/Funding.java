package com.ssafy.funding.entity;

import com.ssafy.funding.dto.request.FundingUpdateRequestDto;
import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
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

    private void update(FundingUpdateRequestDto dto) {
        if (dto.title() != null) this.title = dto.title();
        if (dto.description() != null) this.description = dto.description();
        if (dto.storyFileUrl() != null) this.storyFileUrl = dto.storyFileUrl();
        if (dto.price() != 0) this.price = dto.price();
        if (dto.quantity() != 0) this.quantity = dto.quantity();
        if (dto.targetAmount() != 0) this.targetAmount = dto.targetAmount();
        if (dto.startDate() != null) this.startDate = dto.startDate();
        if (dto.endDate() != null) this.endDate = dto.endDate();
        if (dto.category() != null) this.category = dto.category();
        if (dto.status() != null) this.status = dto.status();
        this.updatedAt = LocalDateTime.now();
    }

    public void applyUpdate(FundingUpdateRequestDto dto) {
        this.update(dto);
    }
}
