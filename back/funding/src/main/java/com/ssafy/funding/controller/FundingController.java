package com.ssafy.funding.controller;

import com.ssafy.funding.service.impl.FundingServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/funding")
@RequiredArgsConstructor
public class FundingController {
    private final FundingServiceImpl fundingServiceImpl;

}
