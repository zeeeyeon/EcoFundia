package com.business.mapper;

import com.business.model.entity.Funding;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MainPageMapper {

    List<Funding> getTopFundingList();

    Long getTotalFund();


}
