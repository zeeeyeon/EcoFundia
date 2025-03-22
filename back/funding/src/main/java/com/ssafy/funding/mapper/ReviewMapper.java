package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.Review;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ReviewMapper {
    void createReview(Review review);
    Review findById(int reviewId);
    List<Review> findByFundingId(int fundingId);
    void updateReview(Review review);
    void deleteReview(int reviewId);
    boolean existsByUserIdAndFundingId(int userId, int fundingId);
}
