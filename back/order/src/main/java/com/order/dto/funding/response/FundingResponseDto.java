package com.order.dto.funding.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class FundingResponseDto {

    private int fundingId;

    private String title;

    private String description;

    @JsonProperty("imageUrl")
    private List<String> imageUrl;

    private LocalDateTime endDate;

    private int currentAmount;

    private String category;

    private String status;

    private int rate;
}
