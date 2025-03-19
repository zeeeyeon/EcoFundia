package com.ssafy.business.mapper;

import com.ssafy.business.entity.Funding;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundingMapper {

    Long getTotalFund();

    List<Funding> getTopFundingList();

    List<Funding> getLatestFundingList(int page);

    List<Funding> getCategoryFundingList(@Param("category") String category, @Param("page") int page);
}
