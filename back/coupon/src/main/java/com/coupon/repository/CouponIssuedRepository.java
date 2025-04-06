package com.coupon.repository;

import com.coupon.entity.Coupon;
import com.coupon.entity.CouponIssued;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CouponIssuedRepository extends JpaRepository<CouponIssued, Integer> {
    boolean existsByUserIdAndCoupon(Integer userId, Coupon coupon);

    @Query("SELECT COUNT(ci) FROM CouponIssued ci WHERE ci.coupon.couponId = :couponId")
    int countByCouponId(@Param("couponId") int couponId);

    @Query("SELECT COUNT(ci) FROM CouponIssued ci WHERE ci.userId = :userId")
    int countByUserId(@Param("userId") int userId);

    @Query("SELECT ci FROM CouponIssued ci WHERE ci.userId = :userId AND ci.isUsed = false")
    List<CouponIssued> findUnusedCouponsByUserId(@Param("userId") int userId);
}
