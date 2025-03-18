package com.ssafy.business.model.entity;

import com.ssafy.business.model.dto.mainPage.getTopFundingResponseDTO;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Funding {

    private int fundingId;
    private int sellerId;
    private String title;
    private String thumbnail;
    private String description;
    private int price;
    private int quantity;           //수량??
    private int targetAmount;       //목표 금액
    private int currentAmount;      //현재 금액
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String status; // ENUM('ONGOING', 'SUCCESS', 'FAIL')
    private String category; // ENUM('FOOD', 'FASHION', 'ELECTRONICS', 'HOUSEHOLD', 'INTERIOR')
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public getTopFundingResponseDTO toDto() {
        return getTopFundingResponseDTO
                .builder()
                .funding_id(fundingId)
                .title(title)
                .description(description)
                .endDate(endDate)
                .rate(currentAmount/targetAmount*100)
                .currentAmount(currentAmount)
                .build();
    }

}
