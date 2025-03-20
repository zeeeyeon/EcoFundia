package com.ssafy.funding.common.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class ExceptionContent {
    private String field;
    private String message;
}
