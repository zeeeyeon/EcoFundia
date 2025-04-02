package com.seller.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderCountResponseDto {
    private List<Integer> orderCount;
    // getters, setters, 생성자 등
}
