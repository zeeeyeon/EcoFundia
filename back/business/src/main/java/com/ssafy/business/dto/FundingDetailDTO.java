package com.ssafy.business.dto;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.entity.Category;
import com.ssafy.business.entity.Status;

import java.time.LocalDateTime;
import java.util.List;

public class FundingDetailDTO {
    private int fundingId;
    private String title;
    private String description;
    private String imageUrls;
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


    // JSON 문자열을 List<String>으로 변환하는 메서드
    public List<String> getImageUrlsAsList() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(imageUrls, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    // List<String>을 JSON 문자열로 변환하는 메서드
    public void setImageUrlsFromList(List<String> urls) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            this.imageUrls = objectMapper.writeValueAsString(urls);
        } catch (Exception e) {
            this.imageUrls = "[]";
        }
    }

//    public FundingDetailResponseDTO toDto() {
//        return FundingDetailResponseDTO
//                .builder()
//                .fundingd(fundingId)
//                .title(title)
//                .description(description)
//                .story(story)
//                .price(price)
//                .quantity(quantity)
//                .targetAmount(targetAmount)
//                .currentAmount(currentAmount)
//                .startDate(startDate)
//                .endDate(endDate)
//                .status(status)
//                .category(category)
//                .sellerId(sellerId)
//                .sellerName(sellerName)
//                .sellerProfileImageUrl(sellerProfileImageUrl)
//                .imageUrls(getImageUrlsAsList()) // 변환된 List<String> 반영
//                .build();
//    }
}
