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
@Table(name = "coupon_issued", uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_coupon", columnNames = {"user_id", "coupon_id"})
})
public class CouponIssued {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int issuedId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    private int userId;
    private boolean isUsed;
    private LocalDateTime usedAt;

    public void use() {
        this.isUsed = true;
        this.usedAt = LocalDateTime.now();
    }
}

