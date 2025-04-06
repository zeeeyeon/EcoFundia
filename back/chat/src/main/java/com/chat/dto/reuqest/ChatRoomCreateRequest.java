package com.chat.dto.reuqest;

import java.util.List;

public record ChatRoomCreateRequest (

    int fundingId,
    String title,
    List<Integer> participants

){}
