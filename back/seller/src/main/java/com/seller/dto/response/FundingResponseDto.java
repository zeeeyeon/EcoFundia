package com.seller.dto.response;

import com.seller.common.util.JsonConverter;

import java.util.List;

public record FundingResponseDto(
        int fundingId,
        String storyFileUrl,
        String imageUrls
) {
    public List<String> imageUrlList() {
        return JsonConverter.convertJsonToImageUrls(imageUrls);
    }
}