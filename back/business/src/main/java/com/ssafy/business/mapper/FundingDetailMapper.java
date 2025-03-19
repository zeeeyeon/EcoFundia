package com.ssafy.business.mapper;

import com.ssafy.business.entity.Review;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface FundingDetailMapper {

    public Object getFundingDetail(int fundingId);

    public List<Review> getReviewList(@Param("fundingId") String fundingId, @Param("page") int page);

}
