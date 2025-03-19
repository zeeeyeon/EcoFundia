package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.entity.Category;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FundingResponseDTO {

    private int funding_id;
    private String title;
    private String description;
    private String imageUrl;
    private LocalDateTime endDate;
    private int currentAmount;
    private Category category;
    private int rate;
}