package com.order.service.impl;

import com.order.client.FundingClient;
import com.order.client.SellerClient;
import com.order.dto.funding.response.IsOngoingResponseDto;
import com.order.dto.order.response.OrderResponseDto;
import com.order.dto.seller.response.SellerAccountResponseDto;
import com.order.dto.ssafyApi.request.HeaderDto;
import com.order.dto.ssafyApi.request.TransferRequestDto;
import com.order.dto.ssafyApi.response.ApiResponseDto;
import com.order.entity.Order;
import com.order.mapper.OrderMapper;
import com.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final FundingClient fundingClient;
    private final SellerClient sellerClient;
    private final com.order.service.ssafyApi.ssafyApiController ssafyApiController;

    @Value("${adm.account}")
    private String adminAccount;

    // 결제 하기
    public OrderResponseDto createOrder(int userId, int fundingId, int quantity, int totalPrice, String userKey, String userAccount){
        int amount = totalPrice / quantity;

        // 1. funding 중인 상품이 현재 펀딩 진행 중인지 확인 (sellerId 받아와아함)
        IsOngoingResponseDto isOngoingResponseDto = fundingClient.isOngoing(fundingId);

        if (isOngoingResponseDto.getIsOngoing()){ // 이미 끝난펀딩이면 종료
            return null;
        }


        // 3. 계좌 이체 하기

        // 3.1 header 만들기
        HeaderDto headerDto = new HeaderDto();

        headerDto.buildHeaderDto("updateDemandDepositAccountTransfer", userKey);

        // 3.2 request 만들기
        TransferRequestDto transferRequestDto = new TransferRequestDto();

        transferRequestDto.buildTransferRequestDto(headerDto, adminAccount, userAccount, Integer.toString(totalPrice) );

        // 요청 보내기
        ApiResponseDto response = ssafyApiController.accountTransfer(transferRequestDto);

        // 계좌이체 실패 하면 예외 처리
        if (response == null || response.getHeader() == null || !"H000".equals(response.getHeader().getResponseCode())){
            return null;
        }

        // 성공하면 order 테이블에 삽입
        OrderResponseDto orderResponseDto = orderMapper.createOrder(userId, fundingId, quantity, amount, quantity);
        return orderResponseDto;
    }

    public List<Order> getOrder(int userId){
        List<Order> orders = orderMapper.getOrders(userId);
        return orders;
    }
}