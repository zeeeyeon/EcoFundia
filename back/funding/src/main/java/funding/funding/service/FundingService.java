package funding.funding.service;

import funding.funding.mapper.FundingMapper;
import funding.funding.model.Funding;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FundingService implements FundingServiceImpl {

    private final FundingMapper fundingMapper;

    public List<Funding> getAllFunding() {
        return fundingMapper.getAllFunding();
    }

    public Funding getFundingById(int fundingId) {
        return fundingMapper.getFundingById(fundingId);
    }

}
