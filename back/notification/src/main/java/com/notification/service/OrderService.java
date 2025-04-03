package com.notification.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrderService {
    private final SimpMessagingTemplate simpMessagingTemplate;

    public OrderService(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void sendToAllTotalOrderAmount(int totalOrderAmount) {
        simpMessagingTemplate.convertAndSend("/topic/totalAmount", totalOrderAmount);
    }

    public void sendPaymentSuccessNotification(String userId, String message) {
        simpMessagingTemplate.convertAndSendToUser(userId, "/paymentSuccess", message);
    }

    public void sendPaymentFailNotification(String userId, String message) {
        simpMessagingTemplate.convertAndSendToUser(userId, "/paymentFail", message);
    }

    public void sendFundingEndNotification(String userId, String message) {
        simpMessagingTemplate.convertAndSendToUser(userId, "/endFunding", message);
    }
}
