package com.ssafy.funding.dto.funding.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.ssafy.funding.common.util.JsonConverter;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.entity.enums.Status;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class MyFundingResponseDto {
    private int fundingId;

    private String title;

    private String description;

    @JsonProperty("imageUrl")
    private List<String> imageUrl;

    private LocalDateTime endDate;

    private int currentAmount;

    private String category;

    private String status;

    private int rate;

    public static MyFundingResponseDto toDto(Funding funding) {
        return MyFundingResponseDto.builder()
                .fundingId(funding.getFundingId())
                .title(funding.getTitle())
                .description(funding.getDescription())
                .imageUrl(JsonConverter.convertJsonToImageUrls(funding.getImageUrls()))
                .endDate(funding.getEndDate())
                .currentAmount(funding.getCurrentAmount())
                .category(funding.getCategory().name())
                .status(funding.getStatus().name())
                .rate((int) ((double) funding.getCurrentAmount() / funding.getTargetAmount() * 100))
                .build();
    }
}
