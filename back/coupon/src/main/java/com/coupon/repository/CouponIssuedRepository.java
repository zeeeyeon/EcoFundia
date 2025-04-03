package com.coupon.repository;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CouponIssuedRepository extends JpaRepository<CouponIssued, Integer> {
    boolean existsByUserIdAndCoupon(Integer userId, Coupon coupon);

    @Query("SELECT COUNT(ci) FROM CouponIssued ci WHERE ci.coupon.couponId = :couponId")
    int countByCouponId(@Param("couponId") int couponId);
}
