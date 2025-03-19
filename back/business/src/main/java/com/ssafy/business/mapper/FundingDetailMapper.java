package com.ssafy.business.mapper;

import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.entity.Review;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundingDetailMapper {

    public FundingDetailResponseDTO getFundingDetail(int fundingId);

    public List<Review> getReviewList(@Param("fundingId") int fundingId, @Param("page") int page);

}
