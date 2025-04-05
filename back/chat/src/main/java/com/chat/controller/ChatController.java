package com.chat.controller;

import com.chat.common.response.Response;
import com.chat.dto.response.ChatMessageResponseDto;
import com.chat.dto.reuqest.ChatMessageRequestDto;

import com.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

import static com.chat.common.response.ResponseCode.*;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/{fundingId}/store")
    public ResponseEntity<?> storeMessages(
            @PathVariable int fundingId,
            @RequestBody List<ChatMessageRequestDto> messages
    ) {
        chatService.storeMessages(messages);
        return new ResponseEntity<>(Response.create(STORE_MESSAGES,null),STORE_MESSAGES.getHttpStatus());
    }

    @GetMapping("/{fundingId}/messages")
    public ResponseEntity<?> getPreviousMessages(
            @PathVariable int fundingId,
            @RequestParam(required = false)LocalDateTime before // 기본값 현재 시간
            ) {
        List<ChatMessageResponseDto> responseDto = chatService.getPreviousMessages(fundingId, before);

        return new ResponseEntity<>(Response.create(GET_MESSAGES,responseDto),GET_MESSAGES.getHttpStatus());
    }

}
