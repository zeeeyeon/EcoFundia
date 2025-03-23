package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailDTO;
import com.ssafy.business.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final FundingClient fundingClient;
    private final SellerClient sellerClient;

    public SellerDetailResponseDTO getSellerDetail(int sellerId) {
        FundingDetailSellerDTO sellerInfo = sellerClient.getSellerInfo(sellerId);
        SellerDetailDTO sellerDetail = fundingClient.getSellerDetail(sellerId);
        return SellerDetailResponseDTO.from(sellerInfo, sellerDetail);
    }

    public SellerDetailDTO getSellerFunding(int sellerId) {
        SellerDetailDTO sellerFunding = fundingClient.getSellerFunding(sellerId);
        return sellerFunding;
    }
}
