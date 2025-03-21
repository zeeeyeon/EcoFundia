package com.ssafy.business.service.impl;

import com.ssafy.business.client.SellerClient;
import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;
import com.ssafy.business.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerClient sellerClient;

    public SellerDetailResponseDTO getSellerDetail(int sellerId) {
        SellerDetailResponseDTO sellerDetial = sellerClient.sellerDetail(sellerId);
        return sellerDetial;
    }
}
