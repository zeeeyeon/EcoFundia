package com.ssafy.business.dto.responseDTO;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FundingResponseDTO {

    private int funding_id;
    private String title;
    private String description;
    private LocalDateTime endDate;
    private int currentAmount;
    private int rate;
}
