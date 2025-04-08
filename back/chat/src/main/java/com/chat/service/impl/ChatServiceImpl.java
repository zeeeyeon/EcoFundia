package com.chat.service.impl;

import com.chat.common.exception.CustomException;
import com.chat.dto.ChatMessageDocument;
import com.chat.dto.response.ChatMessageResponseDto;
import com.chat.dto.reuqest.ChatMessageRequestDto;
import com.chat.repository.ChatMessageRepository;
import com.chat.repository.ChatRoomRepository;
import com.chat.service.ChatRoomService;
import com.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

import static com.chat.common.response.ResponseCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomService chatRoomService;

    @Override
    public void storeMessages(List<ChatMessageRequestDto> messages) {

        List<ChatMessageDocument> docs = messages.stream()
                .map(ChatMessageDocument::fromDto)
                .toList();

        chatMessageRepository.saveAll(docs);
        log.info("✅ Chat 메시지 저장 완료: fundingId={}", docs.size());

        // 가장 최신 메시지 추출
        ChatMessageRequestDto lastMessage = messages.stream()
                .max(Comparator.comparing(ChatMessageRequestDto::getCreatedAt))
                .orElse(null);

        chatRoomService.updateLastMessage(lastMessage.getFundingId(), lastMessage.getContent(), lastMessage.getCreatedAt());
    }


    // 특정 시간 이전의 채팅 메시지 20개씩 조회 (내림차순)
    @Override
    public List<ChatMessageResponseDto> getPreviousMessages(int fundingId, LocalDateTime before){

        //파라미터가 없으면 현재 시간 기준
        LocalDateTime beforeTime = before != null ? before : LocalDateTime.now();

        PageRequest limit = PageRequest.of(0 , 20);

        List<ChatMessageDocument> messages = chatMessageRepository
                .findByFundingIdAndCreatedAtLessThanOrderByCreatedAtDesc(fundingId, beforeTime.plusHours(9), limit);

        List<ChatMessageResponseDto> responseDto = messages.stream()
                .map(ChatMessageDocument::toDto)
                .toList();

        if (responseDto.isEmpty()) {
            throw new CustomException(NO_MESSAGES);
        }
        return responseDto;
    }
}
