package com.ssafy.business.dto.responseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FundingReviewResponseDTO {

    private int reviewId;
    private int fundingId;
    private int userId;
    private String nickname;
    private int rating;
    private String content;
}
