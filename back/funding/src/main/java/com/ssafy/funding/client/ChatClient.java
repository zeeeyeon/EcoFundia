//package com.ssafy.funding.client;
//
//import com.ssafy.funding.dto.chat.request.ChatRoomCreateRequest;
//import com.ssafy.funding.dto.chat.response.ChatRoomCreateResponse;
//import org.springframework.cloud.openfeign.FeignClient;
//import org.springframework.web.bind.annotation.PostMapping;
//import org.springframework.web.bind.annotation.RequestBody;
//
//@FeignClient(name = "chat")
//public interface ChatClient {
//
//    // 채팅방 생성
//    @PostMapping("/api/chatroom")
//    ChatRoomCreateResponse createRoom(@RequestBody ChatRoomCreateRequest request);
//}
