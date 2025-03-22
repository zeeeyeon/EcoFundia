package com.ssafy.funding.dto.seller;

import com.ssafy.funding.entity.enums.Status;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Data
public class SellerFundingDto {

    private int fundingId;
    private String title;
    private String description;
    private List<String> imageUrls;
    private int price;
    private int rate;
    private int remainingDays;
    private Status status;

    public static SellerFundingDto from(SellerDetailDto dto) {
        SellerFundingDto fundingDto = new SellerFundingDto();
        fundingDto.setFundingId(dto.getFundingId());
        fundingDto.setTitle(dto.getTitle());
        fundingDto.setDescription(dto.getDescription());
        fundingDto.setImageUrls(dto.getImageUrls());
        fundingDto.setPrice(dto.getPrice());

        int rate = dto.getTargetAmount() == 0 ? 0 :
                (dto.getCurrentAmount() * 100) / dto.getTargetAmount();
        fundingDto.setRate(rate);

        int remainingDays = (int) ChronoUnit.DAYS.between(LocalDate.now(), dto.getEndDate().toLocalDate());
        fundingDto.setRemainingDays(Math.max(remainingDays, 0));

        fundingDto.setStatus(dto.getStatus());
        return fundingDto;
    }
}
