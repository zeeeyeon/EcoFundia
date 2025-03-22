package com.ssafy.business.dto;

import com.ssafy.business.entity.Status;
import lombok.Data;

import java.util.List;

@Data
public class SellerFundingDTO {

    private int fundingId;
    private String title;
    private String description;
    private List<String> imageUrls;
    private int price;
    private int rate;
    private int remainingDays;
    private Status status;
}
