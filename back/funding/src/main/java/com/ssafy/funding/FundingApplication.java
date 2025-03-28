package com.ssafy.funding;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;

//@EnableFeignClients
@EnableDiscoveryClient
@SpringBootApplication
@EnableFeignClients(basePackages = "com.ssafy.funding.client")
@EnableScheduling
public class FundingApplication {

	public static void main(String[] args) {
		SpringApplication.run(FundingApplication.class, args);
	}

}
