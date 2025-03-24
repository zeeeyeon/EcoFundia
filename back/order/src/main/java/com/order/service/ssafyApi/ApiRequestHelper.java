package com.order.service.ssafyApi;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import static org.apache.tomcat.util.http.FastHttpDateFormat.getCurrentDate;

public class ApiRequestHelper {

    public Map<String, String> commonHeaders(String apiNamePath) {
        Map<String, String> headerMap = new HashMap<>();

        headerMap.put("apiName", getApiName(apiNamePath));
        headerMap.put("transmissionDate", getCurrentDate());
        headerMap.put("transmissionTime", getCurrentTime());
        headerMap.put("institutionCode", getInstitutionCode());
        headerMap.put("fintechAppNo", getFintechAppNo());
        headerMap.put("apiServiceCode", getApiServiceCode(apiNamePath));
        headerMap.put("institutionTransactionUniqueNo", getInstitutionTransactionUniqueNo());
        headerMap.put("apiKey", getApiKey());
        headerMap.put("userKey", getUserKey());

        return headerMap;
    }

    // 🔹 API 이름과 서비스코드는 보통 URL path의 마지막 부분
    private String getApiName(String path) {
        return path;
    }

    private String getApiServiceCode(String path) {
        return path;
    }

    // 현재 날짜 (YYYYMMDD)
    private String getCurrentDate() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    }

    // 현재 시간 (HHMMSS)
    private String getCurrentTime() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("HHmmss"));
    }

    //  기관코드 (고정)
    private String getInstitutionCode() {
        return "00100";
    }

    // 핀테크 앱 번호 (고정)
    private String getFintechAppNo() {
        return "001";
    }

    //  트랜잭션 고유 번호 (날짜+시간+랜덤6자리)
    private String getInstitutionTransactionUniqueNo() {
        String datetime = getCurrentDate() + getCurrentTime();
        String random = String.format("%06d", new Random().nextInt(999999));
        return datetime + random;
    }

    //  API 키
    private String getApiKey() {
        return "db2f69fc7f7e49b8a6460ffe136ca608";
    }

    //  유저 키 (비워도 됨)
    private String getUserKey() {
        return "";
    }



}
