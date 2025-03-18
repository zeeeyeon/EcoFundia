package com.ssafy.business.mapper;

import com.ssafy.business.entity.Funding;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface GetFundingMapper {

    List<Funding> getTopFundingList();

    Long getTotalFund();

    List<Funding> getLatestFundingList();

}
