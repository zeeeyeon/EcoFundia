package com.business.service;

import com.business.model.dto.mainPage.getTopFundingResponseDTO;

import java.util.List;

public  interface MainPageService {

    public List<getTopFundingResponseDTO> getTopFundingList();

    public Long getTotalFund();
}
