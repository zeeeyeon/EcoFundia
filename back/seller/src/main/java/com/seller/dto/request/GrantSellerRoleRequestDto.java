package com.seller.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class GrantSellerRoleRequestDto {
    private String name;
    private String businessNumber;
}
