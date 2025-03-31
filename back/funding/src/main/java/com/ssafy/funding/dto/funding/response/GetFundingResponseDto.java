package com.ssafy.funding.dto.funding.response;


import com.ssafy.funding.entity.enums.Category;
import com.ssafy.funding.entity.enums.Status;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class GetFundingResponseDto {

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

    // 달성률
    private int rate;


}
