package com.ssafy.funding.entity.enums;

import com.fasterxml.jackson.annotation.JsonFormat;

@JsonFormat(shape = JsonFormat.Shape.STRING)
public enum Status {
    ONGOING, SUCCESS, FAIL, CANCEL
}
