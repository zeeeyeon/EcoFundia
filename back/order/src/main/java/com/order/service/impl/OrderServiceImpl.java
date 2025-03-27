package com.order.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.order.client.FundingClient;
import com.order.client.SellerClient;
import com.order.common.exception.CustomException;
import com.order.dto.funding.response.FundingResponseDto;
import com.order.dto.funding.response.IsOngoingResponseDto;
import com.order.dto.ssafyApi.request.HeaderDto;
import com.order.dto.ssafyApi.request.TransferRequestDto;
import com.order.dto.ssafyApi.response.ApiResponseDto;
import com.order.entity.Order;
import com.order.mapper.OrderMapper;
import com.order.service.OrderService;
import com.order.service.ssafyApi.ssafyApiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

import static com.order.common.response.ResponseCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final FundingClient fundingClient;
    private final SellerClient sellerClient;
    private final ssafyApiService ssafyApiService;

    @Value("${adm.account}")
    private String adminAccount;

    @Value("${ssafy.apikey}")
    private String apikey;

    // 결제 하기
    @Transactional
    public Order createOrder(int userId, int fundingId, int quantity, int totalPrice, String userKey, String userAccount){
        int amount = totalPrice / quantity;

        // 1. funding 중인 상품이 현재 펀딩 진행 중인지 확인 (sellerId 받아와아함)
        IsOngoingResponseDto isOngoingResponseDto = fundingClient.isOngoing(fundingId);

        if (!isOngoingResponseDto.getIsOngoing()){ // 이미 끝난펀딩이면 종료
            return null;
        }


        // 3. 계좌 이체 하기
        // 3.1 header 만들기
        HeaderDto headerDto = new HeaderDto().buildHeaderDto("updateDemandDepositAccountTransfer", userKey, apikey);

        // 3.2 request 만들기
        TransferRequestDto transferRequestDto = new TransferRequestDto()
                .buildTransferRequestDto(headerDto, adminAccount, userAccount, totalPrice );

        // 요청 보내기
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(transferRequestDto);
            System.out.println("📦 최종 전송 JSON: " + json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }


        ApiResponseDto response = ssafyApiService.accountTransfer(transferRequestDto);

        // 계좌이체 실패 하면 예외 처리
        if (response == null || response.getHeader().getResponseCode() == null || !"H0000".equals(response.getHeader().getResponseCode())){
            throw new CustomException(SSAFY_API_ERROR, response.getHeader().getResponseCode(),response.getHeader().getResponseMessage());
        }

        // 성공하면 order 테이블에 삽입
        Order order = Order.builder()
                .userId(userId)
                .fundingId(fundingId)
                .quantity(quantity)
                .amount(amount)
                .totalPrice(totalPrice)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        orderMapper.createOrder(order);
        return order;
    }

    public List<Order> getOrder(int userId){
        List<Order> orders = orderMapper.getOrders(userId);
        return orders;
    }

    public int getMyOrderPrice(int userId){
        int price = orderMapper.getMyOrderPrice(userId);
        return price;
    }

    public List<FundingResponseDto> getMyFunding(int userId){
        List<Integer> fundingIds = orderMapper.getMyFundingIds(userId);
        List<FundingResponseDto> fundingList = fundingClient.getMyFunding(fundingIds);
        return fundingList;
    }
}