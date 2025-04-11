package com.coupon.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CouponUsage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int usageId;

    @OneToOne
    @JoinColumn(name = "issued_id")
    private CouponIssued couponIssued;

    private int fundingId;
    private LocalDateTime usedAt;
}