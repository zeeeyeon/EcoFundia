package funding.funding.service;

import funding.funding.model.Funding;

import java.util.List;

public interface FundingServiceImpl {

    public List<Funding> getAllFunding();

    public Funding getFundingById(int fundingId);
}
