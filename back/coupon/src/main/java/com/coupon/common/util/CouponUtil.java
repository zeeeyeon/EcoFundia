package com.coupon.common.util;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

public class CouponUtil {
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyMMdd");

    public static int generateTodayCode() {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));
        return Integer.parseInt(today.format(formatter));
    }
}
