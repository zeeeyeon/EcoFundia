package com.ssafy.funding.service.impl;

import com.ssafy.funding.dto.order.response.IsOngoingResponseDto;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.mapper.OrderMapper;
import com.ssafy.funding.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;

    @Transactional
    public IsOngoingResponseDto isOngoing(int fundingId){
        Funding funding = orderMapper.isOngoing(fundingId);

        if (funding == null) {
            return IsOngoingResponseDto.of(false, 0);
        }
        return IsOngoingResponseDto.of(true,funding.getSellerId());
    }
}
