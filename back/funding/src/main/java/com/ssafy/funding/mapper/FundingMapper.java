package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.Funding;
import org.apache.ibatis.annotations.*;

@Mapper
public interface FundingMapper {

    void createFunding(Funding funding);
    Funding findById(int fundingId);
    void updateFunding(Funding funding);
}
