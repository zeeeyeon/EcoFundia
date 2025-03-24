package com.ssafy.funding.entity;

import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.dto.funding.request.FundingUpdateRequestDto;
import com.ssafy.funding.dto.funding.response.GetFundingResponseDto;
import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Funding {
    private int fundingId;
    private int sellerId;
    private String title;
    private String description;
    private String storyFileUrl;
    private String imageUrls;
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
    public Funding(int sellerId, String title, String description, String storyFileUrl, String imageUrls, int price, int quantity, int targetAmount, LocalDateTime startDate, LocalDateTime endDate, Category category) {
        this.sellerId = sellerId;
        this.title = title;
        this.description = description;
        this.storyFileUrl = storyFileUrl;
        this.imageUrls = imageUrls;
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

    public Funding update(FundingUpdateRequestDto dto, String newStoryFileUrl, List<String> newImageUrls) {
        if (dto.title() != null) this.title = dto.title();
        if (dto.description() != null) this.description = dto.description();
        if (dto.price() != 0) this.price = dto.price();
        if (dto.quantity() != 0) this.quantity = dto.quantity();
        if (dto.targetAmount() != 0) this.targetAmount = dto.targetAmount();
        if (dto.startDate() != null) this.startDate = dto.startDate();
        if (dto.endDate() != null) this.endDate = dto.endDate();
        if (dto.category() != null) this.category = dto.category();
        if (dto.status() != null) this.status = dto.status();

        if (newStoryFileUrl != null) this.storyFileUrl = newStoryFileUrl;
        if (newImageUrls != null && !newImageUrls.isEmpty()) {
            this.imageUrls = JsonConverter.convertImageUrlsToJson(newImageUrls);
        }

        this.updatedAt = LocalDateTime.now();
        return this;
    }

    public List<String> getImageUrlList() {
        return JsonConverter.convertJsonToImageUrls(this.imageUrls);
    }


    public GetFundingResponseDto toDto() {
        return GetFundingResponseDto
                .builder()
                .fundingId(fundingId)
                .sellerId(sellerId)
                .title(title)
                .storyFileUrl(storyFileUrl)
                .imageUrls(JsonConverter.convertJsonToImageUrls(imageUrls))
                .description(description)
                .price(price)
                .quantity(quantity)
                .targetAmount(targetAmount)
                .currentAmount(currentAmount)
                .startDate(startDate)
                .endDate(endDate)
                .status(status)
                .category(category)
                .rate( (int) ((double) currentAmount / targetAmount * 100) )
                .build();
    }
}
