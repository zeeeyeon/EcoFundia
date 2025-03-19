package com.ssafy.business.mapper;

import com.ssafy.business.dto.FundingDetailDTO;
import com.ssafy.business.dto.ReviewDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundingDetailMapper {

    public FundingDetailDTO getFundingDetail(int fundingId);

    public List<ReviewDTO> getReviewList(@Param("fundingId") int fundingId, @Param("page") int page);

}
