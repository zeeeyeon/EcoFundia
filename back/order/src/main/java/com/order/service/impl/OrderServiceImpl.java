package com.order.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.order.client.FundingClient;
import com.order.client.SellerClient;
import com.order.client.UserClient;
import com.order.common.exception.CustomException;
import com.order.dto.funding.request.GetAgeListRequestDto;
import com.order.dto.funding.request.GetSellerFundingDetailOrderListRequestDto;
import com.order.dto.funding.response.*;
import com.order.dto.funding.request.GetSellerTodayOrderCountRequestDto;
import com.order.dto.funding.request.GetSellerTodayOrderTopThreeListRequestDto;
import com.order.dto.seller.response.GetSellerMonthAmountStatisticsResponseDto;
import com.order.dto.funding.response.GetSellerTodayOrderCountResponseDto;
import com.order.dto.funding.response.GetSellerTodayOrderTopThreeIdAndMoneyResponseDto;
import com.order.dto.funding.response.IsOngoingResponseDto;
import com.order.dto.order.response.OrderResponseDto;
import com.order.dto.ssafyApi.request.HeaderDto;
import com.order.dto.ssafyApi.request.TransferRequestDto;
import com.order.dto.ssafyApi.response.ApiResponseDto;
import com.order.dto.user.response.GetSellerFundingDetailOrderUserInfoListResponseDto;
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
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static com.order.common.response.ResponseCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final FundingClient fundingClient;
    private final SellerClient sellerClient;
    private final ssafyApiService ssafyApiService;
    private final UserClient userClient;

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
            throw new CustomException(FUNDING_NOT_ONGOING);
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

    @Override
    public GetSellerTodayOrderCountResponseDto getSellerTodayOrderCount(GetSellerTodayOrderCountRequestDto getSellerTodayOrderCountRequestDto) {
        int todayOrderCount = orderMapper.getSellerTodayOrderCount(getSellerTodayOrderCountRequestDto.getFundingIdList());
        return GetSellerTodayOrderCountResponseDto
                .builder()
                .todayOrderCount(todayOrderCount)
                .build();
    }

    @Override
    public List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> getSellerTodayOrderTopThreeList(GetSellerTodayOrderTopThreeListRequestDto getSellerTodayOrderTopThreeListRequestDto) {
        System.out.println("서비스 호출됨");
        System.out.println(getSellerTodayOrderTopThreeListRequestDto.getFundingIdList());
        List<Order> orderTopThreeList = orderMapper.getSellerTodayOrderTopThreeList(getSellerTodayOrderTopThreeListRequestDto.getFundingIdList());
        System.out.println("쿼리 결과: " + orderMapper.getSellerTodayOrderTopThreeList(getSellerTodayOrderTopThreeListRequestDto.getFundingIdList()));
        List<GetSellerTodayOrderTopThreeIdAndMoneyResponseDto> orderList = orderTopThreeList.stream()
                .map(Order::toGetSellerTodayOrderTopThreeIdAndMoneyResponseDto)
                .collect(Collectors.toList());
        if(orderList.isEmpty()) {
            return new ArrayList<>();
        }
        System.out.println("결과 DTO: " + orderList);
        return orderList;
    }

    @Override
    public List<GetSellerFundingDetailOrderListResponseDto> getSellerFundingDetailOrderList(int fundingId, int page) {

        List<Order> orderList = orderMapper.getSellerFundingDetailOrderList(fundingId, page);
        System.out.println(orderList);

        List<GetSellerFundingDetailOrderListResponseDto> result = new ArrayList<>();

        if(!orderList.isEmpty()) {
            List<Integer> userIdList = orderList.stream().map(Order::getUserId).collect(Collectors.toList());

            System.out.println(userIdList);
            GetSellerFundingDetailOrderListRequestDto getSellerFundingDetailOrderListRequestDto = GetSellerFundingDetailOrderListRequestDto
                    .builder()
                    .userIdList(userIdList)
                    .build();

            System.out.println(getSellerFundingDetailOrderListRequestDto);

            List<GetSellerFundingDetailOrderUserInfoListResponseDto> userList = userClient.getSellerFundingDetailOrderList(getSellerFundingDetailOrderListRequestDto);

            for(int i = 0; i < orderList.size(); i++) {
                result.add(GetSellerFundingDetailOrderListResponseDto
                        .builder()
                                .orderId(orderList.get(i).getOrderId())
                                .userId(orderList.get(i).getUserId())
                                .name(userList.get(i).getName())
                                .nickname(userList.get(i).getNickname())
                                .createdAt(orderList.get(i).getCreatedAt())
                                .totalPrice(orderList.get(i).getTotalPrice())
                                .quantity(orderList.get(i).getQuantity())
                        .build()
                );
            }
        }
        return result;
    }

    @Override
    public List<GetSellerMonthAmountStatisticsResponseDto> getSellerMonthAmountStatistics(List<Integer> fundingIdList) {
        List<Order> orderList = orderMapper.getSellerMonthAmountStatistics(fundingIdList);
        return orderList.stream().map(Order::toGetSellerMonthAmountStatisticsResponseDto).collect(Collectors.toList());
    }

    @Override
    public List<GetSellerFundingDetailStatisticsResponseDto> getSellerFundingDetailStatistics(int fundingId) {
        List<GetSellerFundingDetailStatisticsResponseDto> result = new ArrayList<>();
        List<Integer> userIdList = orderMapper.getSellerFundingDetailStatistics(fundingId);
        List<GetAgeListRequestDto> ageListRequestDtoList = userIdList.stream()
                .map(userIdTarget -> new GetAgeListRequestDto(userIdTarget))
                .collect(Collectors.toList());
        List<Integer> userStatistics = userClient.getAgeList(ageListRequestDtoList);
        int totalCount = 0;
        for(int count: userStatistics) {
            totalCount += count;
        }
        if(totalCount == 0) return result;

        for (int i = 0; i < userStatistics.size(); i++) {
            double percentage = (double) userStatistics.get(i) / totalCount * 100;
            result.add(new GetSellerFundingDetailStatisticsResponseDto((i + 1) * 10, Math.round(percentage * 10) / 10.0));
        }

        return result;
    }

    @Override
    public List<Integer> getSellerBrandStatistics(List<Integer> userIdList) {
        return orderMapper.getSellerBrandStatistics(userIdList);
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