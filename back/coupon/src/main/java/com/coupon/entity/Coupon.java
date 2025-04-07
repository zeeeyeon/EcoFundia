package com.coupon.entity;

import com.coupon.common.exception.CustomException;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static com.coupon.common.response.ResponseCode.COUPON_EXPIRED;

@Entity
@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Coupon {
    private static final Logger log = LoggerFactory.getLogger(Coupon.class);
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int couponId;

    @Column(unique = true)
    private int couponCode;
    private int totalQuantity;
    private int discountAmount;

    private LocalDateTime startDate;
    private LocalDateTime endDate;

    private LocalDateTime createAt;

    @OneToMany(mappedBy = "coupon", cascade = CascadeType.ALL)
    private List<CouponIssued> issuedList = new ArrayList<>();

    public static Coupon create(int couponCode, int totalQuantity, int discountAmount,
                                LocalDateTime startDate, LocalDateTime endDate) {
        Coupon coupon = new Coupon();
        coupon.couponCode = couponCode;
        coupon.totalQuantity = totalQuantity;
        coupon.discountAmount = discountAmount;
        coupon.startDate = startDate;
        coupon.endDate = endDate;
        coupon.createAt = LocalDateTime.now();
        return coupon;
    }

    public boolean isValid() {
        LocalDateTime now = LocalDateTime.now();
        return now.isAfter(startDate) && now.isBefore(endDate);
    }

    public void validateIssuable() {
        if (!isValid()) {
            log.warn("쿠폰 [{}] 기간 만료 (start: {}, end: {})", couponCode, startDate, endDate);
            throw new CustomException(COUPON_EXPIRED);
        }
    }
}
