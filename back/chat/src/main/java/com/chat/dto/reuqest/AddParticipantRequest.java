package com.chat.dto.reuqest;

import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class AddParticipantRequest {

    private int userId;


}