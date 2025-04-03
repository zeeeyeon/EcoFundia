package com.notification.controller;

import com.notification.common.response.Response;
import com.notification.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.notification.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/notification")
public class OrderNotificationController {

    @Autowired
    OrderService orderService;

    @PostMapping("/total-order-amount")
    public ResponseEntity<?> sendToAllTotalOrderAmount(@RequestBody int totalOrderAmount) {
        orderService.sendToAllTotalOrderAmount(totalOrderAmount);
        return new ResponseEntity<>(Response.create(SEND_TO_ALL_TOTAL_ORDER_AMOUNT, null), SEND_TO_ALL_TOTAL_ORDER_AMOUNT.getHttpStatus());
    }

    @PostMapping("/pay-success")
    public ResponseEntity<?> sendPaymentSuccessNotification(@RequestParam("userId") String userId, @RequestBody String message) {
        orderService.sendPaymentSuccessNotification(userId, message);
        return new ResponseEntity<>(Response.create(SEND_PAYMENT_SUCCESS_NOTIFICATION, null), SEND_PAYMENT_SUCCESS_NOTIFICATION.getHttpStatus());
    }

    @PostMapping("/pay-fail")
    public ResponseEntity<?> sendPaymentFailNotification(@RequestParam("userId") String userId, @RequestBody String message) {
        orderService.sendPaymentFailNotification(userId, message);
        return new ResponseEntity<>(Response.create(SEND_PAYMENT_FAIL_NOTIFICATION, null), SEND_PAYMENT_FAIL_NOTIFICATION.getHttpStatus());
    }

    @PostMapping("/funding-end")
    public ResponseEntity<?> sendFundingEndNotification(@RequestParam("userId") String userId, @RequestBody String message) {
        orderService.sendFundingEndNotification(userId, message);
        return new ResponseEntity<>(Response.create(SEND_FUNDING_END_NOTIFICATION, null), SEND_FUNDING_END_NOTIFICATION.getHttpStatus());
    }

}
