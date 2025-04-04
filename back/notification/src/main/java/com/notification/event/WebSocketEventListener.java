package com.notification.event;

import com.notification.client.FundingClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

@Component
public class WebSocketEventListener {
    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private SimpMessagingTemplate simpMessagingTemplate;

    @Autowired
    private FundingClient fundingClient;

    private static final String TOTAL_FUND_KEY = "total_fund";

    @EventListener(SessionSubscribeEvent.class)
    public void handleSubscriptionEvent(SessionSubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = headerAccessor.getDestination();

        // 사용자가 "/topic/totalAmount" 구독 시 실행
        if ("/topic/totalAmount".equals(destination)) {
            String totalFundStr = redisTemplate.opsForValue().get(TOTAL_FUND_KEY);
//            Long totalFund = Long.parseLong(redisTemplate.opsForValue().get(TOTAL_FUND_KEY));
            Long totalFund = (totalFundStr != null) ? Long.parseLong(totalFundStr) : null;
            if (totalFundStr == null) {
                totalFund = fundingClient.getTotalFund();  // Redis에 없으면 조회
                redisTemplate.opsForValue().set(TOTAL_FUND_KEY, String.valueOf(totalFund));
            }
            simpMessagingTemplate.convertAndSend("/topic/totalAmount", totalFund);
        }
    }
}
