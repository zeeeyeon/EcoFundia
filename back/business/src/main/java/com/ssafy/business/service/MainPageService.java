package com.ssafy.business.service;

import com.ssafy.business.model.dto.mainPage.getTopFundingResponseDTO;

import java.util.List;

public  interface MainPageService {

    public List<getTopFundingResponseDTO> getTopFundingList();

    public Long getTotalFund();
}
