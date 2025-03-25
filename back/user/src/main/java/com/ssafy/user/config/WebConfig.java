//package com.ssafy.user.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.web.servlet.config.annotation.CorsRegistry;
//import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
//
//@Configuration
//public class WebConfig {
//
//    @Bean
//    public WebMvcConfigurer corsConfigurer() {
//        return new WebMvcConfigurer() {
//            @Override
//            public void addCorsMappings(CorsRegistry registry) {
//                registry.addMapping("/**")
//                        .allowedOriginPatterns("*") // 허용할 오리진 주소
//                        .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
//                        .allowCredentials(true);
//            }
//        };
//    }
//}
