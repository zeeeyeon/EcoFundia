package com.seller.client;

import com.seller.config.FeignMultipartSupportConfig;
import org.springframework.cloud.openfeign.FeignClient;

@FeignClient(name = "funding", configuration = FeignMultipartSupportConfig.class)
public interface FundingClient {


}
