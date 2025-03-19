package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.entity.Category;
import com.ssafy.business.entity.Status;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class FundingDetailResponseDTO {

    private int fundingId;
    private String title;
    private String description;
    private List<String> imageUrls;
    private String story;
    private int price;
    private int quantity;
    private int targetAmount;
    private int currentAmount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Status status;
    private Category category;

    private int sellerId;
    private String sellerName; //현재 이거 없음
    private String sellerProfileImageUrl;

}
