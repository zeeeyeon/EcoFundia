package com.ssafy.funding.service;

import com.ssafy.funding.dto.order.response.IsOngoingResponseDto;


public interface OrderService {

    // 결제전 현재 펀딩이 진행중인지 확인
    IsOngoingResponseDto isOngoing(int fundingId);
}
