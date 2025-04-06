package com.notification.dto.request;

public record AddParticipantRequest(
        int userId
) {
    public AddParticipantRequest from(int userId) {
        return new AddParticipantRequest(userId);
    }
}
