package funding.funding.model.service;

import funding.funding.model.entity.Funding;

import java.util.List;

public interface FundingServiceImpl {

    public List<Funding> getAllFunding();

    public Funding getFundingById(int fundingId);
}
