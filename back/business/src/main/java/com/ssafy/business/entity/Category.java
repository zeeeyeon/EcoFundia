package com.ssafy.business.entity;

import com.fasterxml.jackson.annotation.JsonFormat;

@JsonFormat(shape = JsonFormat.Shape.STRING)
public enum Category {
    FASHION, ELECTRONICS, HOUSEHOLD, INTERIOR, FOOD
}
