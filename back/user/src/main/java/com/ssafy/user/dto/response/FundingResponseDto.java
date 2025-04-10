package com.ssafy.user.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.List;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FundingResponseDto {
    private int fundingId;

    private String title;

    private int totalPrice;

    private String description;

    @JsonProperty("imageUrl")
    private List<String> imageUrl;

    private LocalDateTime endDate;

    private int currentAmount;

    private String category;

    private String status;

    private int rate;
}
