package com.seller.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.concurrent.ConcurrentTaskScheduler;

/**
 * Seller 서비스의 TaskScheduler 빈 설정
 * - 예약된 정산 작업 실행에 사용됨
 */
@Configuration
public class SchedulerConfig {
    @Bean
    public TaskScheduler taskScheduler() {
        return new ConcurrentTaskScheduler();
    }
}
