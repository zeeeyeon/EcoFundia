package funding.funding.service;

import funding.funding.client.FundingReviewFeignClient;
import funding.funding.model.FundingReview;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FundingReviewService {

    private final FundingReviewFeignClient fundingReviewFeignClient;

    public FundingReviewService(FundingReviewFeignClient fundingReviewFeignClient) {
        this.fundingReviewFeignClient = fundingReviewFeignClient;
    }

    public List<FundingReview> getReviews(int fundingId) {
        return fundingReviewFeignClient.getReviewsByFundingId(fundingId);
    }
}
