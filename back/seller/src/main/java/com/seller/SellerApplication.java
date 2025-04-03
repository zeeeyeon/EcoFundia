package com.seller;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableFeignClients(basePackages = "com.seller.client")
@EnableDiscoveryClient
@SpringBootApplication
@EnableScheduling
public class SellerApplication {

	public static void main(String[] args) {
		SpringApplication.run(SellerApplication.class, args);
	}

}
