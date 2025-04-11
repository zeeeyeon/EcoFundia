package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.common.exception.CustomException;
import com.ssafy.business.dto.ReviewDTO;
import com.ssafy.business.dto.responseDTO.FundingDetailResponseDTO;
import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.FundingResponseDTO;
import com.ssafy.business.dto.responseDTO.ReviewResponseDTO;
import com.ssafy.business.service.FundingDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import static com.ssafy.business.common.response.ResponseCode.*;
@Service
@RequiredArgsConstructor
public class FundingDetailServiceImpl implements FundingDetailService {

    private final SellerClient sellerClient;
    private final FundingClient fundingClient;

    // 펀딩 상세 페이지
    public FundingDetailResponseDTO getFundingDetail(int fundingId){
        FundingResponseDTO fundingInfo = fundingClient.getFundingDetail(fundingId); //null은 funding에서 처리
        FundingDetailSellerDTO sellerInfo = sellerClient.getSellerInfo(fundingInfo.getSellerId());
        if (sellerInfo == null) {
            throw new CustomException(SELLER_NOT_FOUND);
        }
        return FundingDetailResponseDTO.from(fundingInfo, sellerInfo);
    }

    // 펀딩 리뷰 조회
    public ReviewResponseDTO getFundingReview(int sellerId, int page) {

        ReviewResponseDTO reviewList = fundingClient.getFundingReview(sellerId, page);

        List<ReviewDTO> pagedList = pagenate(reviewList.getReviews(), page, 5);

        ReviewResponseDTO responseDTO = ReviewResponseDTO.builder()
                .totalRating(reviewList.getTotalRating())
                .reviews(pagedList)
                .build();

        return responseDTO;
    }

    private List<ReviewDTO> pagenate(List<ReviewDTO> list, int page, int size) {
        int total = list.size();
        int start= Math.min((page -1) * size, total);
        int end = Math.min(start + size, total);
        List<ReviewDTO> reviewList = list.subList(start, end);
        return reviewList;
    }

}


