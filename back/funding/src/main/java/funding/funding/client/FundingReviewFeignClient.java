package funding.funding.client;

import funding.funding.model.FundingReview;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name =  "funding-review-service", path = "/api/funding-review")
public interface FundingReviewFeignClient {

    @GetMapping("/{fundingId}")
    List<FundingReview> getReviewsByFundingId(@PathVariable("fundingId") int fundingId);
}
