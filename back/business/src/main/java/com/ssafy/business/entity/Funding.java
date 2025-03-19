package com.ssafy.business.entity;

import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Funding {

    private int fundingId;
    private int sellerId;
    private String title;
    private String imageUrls;
    private String description;
    private int price;
    private int quantity;           //수량??
    private int targetAmount;       //목표 금액
    private int currentAmount;      //현재 금액
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Status status; // ENUM('ONGOING', 'SUCCESS', 'FAIL')
    private Category category; // ENUM('FOOD', 'FASHION', 'ELECTRONICS', 'HOUSEHOLD', 'INTERIOR')
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public FundingResponseDTO toDto() {
        return FundingResponseDTO
                .builder()
                .funding_id(fundingId)
                .title(title)
                .description(description)
                .imageUrl(imageUrls)
                .endDate(endDate)
                .rate( (int) ((double) currentAmount / targetAmount * 100) )
                .currentAmount(currentAmount)
                .category(category)
                .build();
    }

}
