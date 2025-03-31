package com.coupon.repository;

import com.coupon.entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CouponRepository extends JpaRepository<Coupon, Integer> {
    Optional<Coupon> findByCouponCode(int couponCode);
    boolean existsByCouponCode(int couponCode);
}
