package com.ssafy.funding.config;

import com.ssafy.funding.entity.typeHandlers.CategoryTypeHandler;
import com.ssafy.funding.entity.typeHandlers.StatusTypeHandler;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MyBatisConfig {

    @Bean
    public ConfigurationCustomizer configurationCustomizer() {
        return configuration -> {
            configuration.getTypeHandlerRegistry().register(StatusTypeHandler.class);
            configuration.getTypeHandlerRegistry().register(CategoryTypeHandler.class);
        };
    }
}
