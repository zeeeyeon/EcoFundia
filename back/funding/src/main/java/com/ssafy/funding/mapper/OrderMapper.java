package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.Funding;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderMapper {

    Funding isOngoing(int fundingId);
}
