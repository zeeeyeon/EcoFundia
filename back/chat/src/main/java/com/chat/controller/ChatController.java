package com.chat.controller;

import com.chat.dto.ChatMessageDocument;
import com.chat.dto.ChatMessageDto;

import com.chat.repository.ChatMessageRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/chat")
public class ChatController {

    private final ChatMessageRepository chatMessageRepository;

    @PostMapping("/{fundingId}/store")
    public ResponseEntity<Void> storeMessages(
            @PathVariable int fundingId,
            @RequestBody List<ChatMessageDto> messages
    ) {
        List<ChatMessageDocument> docs = messages.stream()
                .map(dto -> ChatMessageDocument.fromDto(dto))
                .toList();

        chatMessageRepository.saveAll(docs);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{fundingId}/history")
    public ResponseEntity<List<ChatMessageDto>> getChatHistory(
            @PathVariable int fundingId,
            @RequestParam(required = false) String lastId,  // 커서 방식
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(0, size, Sort.by(Sort.Direction.DESC, "_id"));
        List<ChatMessageDocument> results;

        if (lastId != null) {
            ObjectId lastObjectId = new ObjectId(lastId);
            results = chatMessageRepository.findByFundingIdAndIdBefore(fundingId, lastObjectId, pageable);
        } else {
            results = chatMessageRepository.findByFundingIdOrderByIdDesc(fundingId, pageable);
        }

        List<ChatMessageDto> dtoList = results.stream()
                .map(ChatMessageDocument::toDto)
                .toList();

        return ResponseEntity.ok(dtoList);
    }

}
