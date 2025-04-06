package com.ssafy.funding.dto.chat.request;

import com.ssafy.funding.entity.Funding;

import java.util.List;

public record ChatRoomCreateRequest(

    int fundingId,
    String title,
    List<Integer> participants

){

    // 펀딩 정보 기반 채팅방 생성 DTO
    public static ChatRoomCreateRequest from(Funding funding){
        return new ChatRoomCreateRequest(
                funding.getFundingId(),
                funding.getTitle(),
                List.of()
        );
    }
}
