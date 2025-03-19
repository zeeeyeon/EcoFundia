package com.ssafy.business.dto.responseDTO;

import com.ssafy.business.entity.Category;
import com.ssafy.business.entity.Status;
import lombok.Builder;
import lombok.Data;
import org.apache.commons.lang.enums.Enum;

import java.time.LocalDateTime;

@Data
@Builder
public class FundingDetailResponseDTO {

    private int fundingId;
    private String title;
    private String description;
    private String imageUrl; // 이미지 url도 없음
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
