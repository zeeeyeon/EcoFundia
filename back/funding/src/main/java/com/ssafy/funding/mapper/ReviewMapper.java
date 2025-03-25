package com.ssafy.funding.mapper;

import com.ssafy.funding.dto.review.response.ReviewDto;
import com.ssafy.funding.entity.Review;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ReviewMapper {
    void createReview(Review review);
    Review findById(int reviewId);
    List<Review> findByFundingId(int fundingId);
    List<Review> findBySellerId(int sellerId);
    List<ReviewDto> findByUserId(int userId);
    void updateReview(Review review);
    void deleteReview(int reviewId);
    boolean existsByUserIdAndFundingId(int userId, int fundingId);
}
