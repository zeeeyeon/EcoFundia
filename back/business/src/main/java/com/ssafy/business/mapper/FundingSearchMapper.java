package com.ssafy.business.mapper;

import com.ssafy.business.entity.Funding;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundingSearchMapper {

    List<Funding> getSearchFunding(@Param("keyword") String keyword, @Param("page") int page);
}
