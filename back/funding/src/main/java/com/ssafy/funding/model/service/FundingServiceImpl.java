package com.ssafy.funding.model.service;

import com.ssafy.funding.model.entity.Funding;

import java.util.List;

public interface FundingServiceImpl {

    public List<Funding> getAllFunding();

    public Funding getFundingById(int fundingId);
}
