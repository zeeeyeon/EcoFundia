package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.entity.Category;
import com.ssafy.business.entity.Status;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;


@Data
@Builder
public class FundingWishCountResponseDto {

    private int fundingId;
    private int sellerId;
    private String title;
    private String description;
    private String storyFileUrl;
    private List<String> imageUrls;
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

    private int rate;
    private int wishCount;
}
