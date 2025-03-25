package com.seller.common.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Collections;
import java.util.List;

public class JsonConverter {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static String convertImageUrlsToJson(List<String> imageUrlList) {
        try {
            return objectMapper.writeValueAsString(imageUrlList);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("이미지 URL 리스트를 JSON으로 변환하는 데 실패하였습니다.", e);
        }
    }

    public static List<String> convertJsonToImageUrls(String json) {
        if (json == null || json.isBlank()) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}