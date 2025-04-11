package com.ssafy.business.service.impl;

import com.ssafy.business.client.FundingClient;
import com.ssafy.business.client.SellerClient;
import com.ssafy.business.common.exception.CustomException;
import com.ssafy.business.dto.FundingDetailSellerDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailDTO;
import com.ssafy.business.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import static com.ssafy.business.common.response.ResponseCode.*;

@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final FundingClient fundingClient;
    private final SellerClient sellerClient;

    public SellerDetailResponseDTO getSellerDetail(int sellerId) {
        FundingDetailSellerDTO sellerInfo = sellerClient.getSellerInfo(sellerId);

        if (sellerInfo == null) {
            throw new CustomException(SELLER_NOT_FOUND);
        }

        SellerDetailDTO sellerDetail = fundingClient.getSellerDetail(sellerId);
        return SellerDetailResponseDTO.from(sellerInfo, sellerDetail);
    }

    public SellerDetailDTO getSellerFunding(int sellerId) {
        SellerDetailDTO sellerFunding = fundingClient.getSellerFunding(sellerId);

        return sellerFunding;
    }
}
