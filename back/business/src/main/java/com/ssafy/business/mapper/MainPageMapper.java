package com.ssafy.business.mapper;

import com.ssafy.business.model.entity.Funding;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MainPageMapper {

    List<Funding> getTopFundingList();

    Long getTotalFund();


}
