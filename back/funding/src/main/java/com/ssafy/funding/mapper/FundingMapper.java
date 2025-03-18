package com.ssafy.funding.mapper;

import com.ssafy.funding.model.entity.Funding;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface FundingMapper {

    // 전체 펀딩 조회
    List<Funding> getAllFunding();

    Funding getFundingById(int fundingId);

}
