package com.seller.dto.ssafyApi.request;

import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class HeaderDto {

    private String apiName;
    private String transmissionDate;
    private String transmissionTime;
    private String institutionCode;
    private String fintechAppNo;
    private String apiServiceCode;
    private String institutionTransactionUniqueNo;
    private String apiKey;
    private String userKey;

    public HeaderDto buildHeaderDto(String apiName, String userKey, String apiKey) {


        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HHmmss"));
        String transactionId = date + time + String.format("%06d", new Random().nextInt(999999));

        return HeaderDto.builder()
                .apiName(apiName)
                .transmissionDate(date)
                .transmissionTime(time)
                .institutionCode("00100")
                .fintechAppNo("001")
                .apiServiceCode(apiName)
                .institutionTransactionUniqueNo(transactionId)
                .apiKey(apiKey)
                .userKey(userKey)
                .build();
    }
}
