package com.notification.dto.request;

public record AddParticipantRequest(
        int userId
) {
    public static AddParticipantRequest from(int userId) {
        return new AddParticipantRequest(userId);
    }
}
