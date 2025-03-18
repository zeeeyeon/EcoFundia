package com.ssafy.business.service;

import com.ssafy.business.mapper.MainPageMapper;
import com.ssafy.business.model.dto.mainPage.getTopFundingResponseDTO;
import com.ssafy.business.model.entity.Funding;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MainPageServiceImpl implements MainPageService {

    private final MainPageMapper mainPageMapper;

    public List<getTopFundingResponseDTO> getTopFundingList(){
        List<Funding> fundingList = mainPageMapper.getTopFundingList();
        return fundingList.stream().map(Funding::toDto).collect(Collectors.toList());

    }

    public Long getTotalFund(){
        return mainPageMapper.getTotalFund();
    }
}


