package funding.funding.model.service;

import funding.funding.model.dto.mainPage.getTopFundingResponseDTO;
import funding.funding.model.entity.Funding;

import java.util.List;

public  interface MainPageService {

    public List<getTopFundingResponseDTO> getTopFundingList();

    public Long getTotalFund();
}
