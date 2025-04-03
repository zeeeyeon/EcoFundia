package com.notification.client;

import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name="notification")
public interface NotificationClient {
}
