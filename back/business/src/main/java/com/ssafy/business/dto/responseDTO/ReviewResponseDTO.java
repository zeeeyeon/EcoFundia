package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.dto.ReviewDTO;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Builder
@Data
public class ReviewResponseDTO {

    private float totalRating;
    private List<ReviewDTO> reviews;
}
