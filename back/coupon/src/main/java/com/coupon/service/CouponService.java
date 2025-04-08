package com.coupon.service;

import com.coupon.common.exception.CustomException;
import com.coupon.dto.CouponIssuedDto;
import com.coupon.dto.CouponResponseDto;
import com.coupon.dto.CouponUsageRequestDto;
import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import com.coupon.entity.CouponUsage;
import com.coupon.repository.CouponIssuedRepository;
import com.coupon.repository.CouponRepository;
import com.coupon.repository.CouponUsageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

import static com.coupon.common.response.ResponseCode.*;
import static com.coupon.common.util.CouponUtil.generateTodayCode;

@Slf4j
@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponRepository couponRepository;
    private final CouponIssuedRepository couponIssuedRepository;
    private final CouponUsageRepository couponUsageRepository;

    @Transactional
    public void issueCoupon(int userId) {
        // 1. 해당 코드의 쿠폰이 존재하는지 확인 (코드는 해당 날짜)
        int couponCode = generateTodayCode();
        Coupon coupon = couponRepository.findByCouponCodeWithLock(couponCode)
                .orElseThrow(() -> {
                    log.warn("쿠폰 코드 [{}] 존재하지 않음", couponCode);
                    return new CustomException(COUPON_NOT_FOUND);
                });

        // 1-1. 쿠폰 시간 validation
        coupon.validateIssuable();

        // 2. 이전에 받은 기록이 있는지 확인
        if (couponIssuedRepository.existsByUserIdAndCoupon(userId, coupon)) {
            log.warn("userId {} 이미 쿠폰 [{}] 발급받음", userId, coupon.getCouponCode());
            throw new CustomException(COUPON_ALREADY_ISSUED);
        }

        // 3. 해당 코드의 쿠폰의 수량이 남았는지 확인
        int issuedCount = couponIssuedRepository.countByCouponId(coupon.getCouponId());
        if (issuedCount >= coupon.getTotalQuantity()) {
            log.warn("쿠폰 [{}] 수량 초과 (현재 발급: {}, 총 수량: {})", coupon.getCouponCode(), issuedCount, coupon.getTotalQuantity());
            throw new CustomException(COUPON_OUT_OF_STOCK);
        }
        CouponIssued issued = CouponIssuedDto.toEntity(coupon, userId);
        couponIssuedRepository.save(issued);
    }

    public int countCoupon(int userId) {
        List<CouponIssued> issuedList = couponIssuedRepository.findUnusedCouponsByUserId(userId);
        return issuedList.size();
    }

    @Transactional(readOnly = true)
    public List<CouponResponseDto> getCoupons(int userId) {
        List<CouponIssued> issuedList = couponIssuedRepository.findUnusedCouponsByUserId(userId);
        log.info("issuedList size: {}", issuedList.size());
        return issuedList.stream()
                .peek(i -> log.info("Coupon ID: {}", i.getCoupon().getCouponId()))
                .map(c -> CouponResponseDto.from(c.getCoupon()))
                .collect(Collectors.toList());
    }

    public CouponResponseDto getCouponInfo(int couponId) {
        Coupon coupon = couponRepository.findById(couponId)
                .orElseThrow(() -> new CustomException(COUPON_NOT_FOUND));
        return CouponResponseDto.from(coupon);
    }

    @Transactional
    public void useCoupon(int userId, int couponId, int fundingId) {
        CouponIssued issuedCoupon = couponIssuedRepository.findValidIssuedCoupon(userId, couponId)
                .orElseThrow(() -> new CustomException(COUPON_NOT_FOUND));

        Coupon coupon = issuedCoupon.getCoupon();
        coupon.validateIssuable();

        issuedCoupon.use();

        CouponUsage usage = new CouponUsageRequestDto(userId, fundingId, couponId)
                .toEntity(issuedCoupon);

        couponUsageRepository.save(usage);
    }
}
