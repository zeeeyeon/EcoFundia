package com.chat.service;


import com.chat.dto.response.ChatMessageResponseDto;
import com.chat.dto.reuqest.ChatMessageRequestDto;

import java.time.LocalDateTime;
import java.util.List;

public interface ChatService {

    void storeMessages(List<ChatMessageRequestDto> messages);

    // 특정 시간 이전의 채팅 메시지 20개씩 조회 (내림차순)
    List<ChatMessageResponseDto> getPreviousMessages(int fundingId, LocalDateTime before);


}
