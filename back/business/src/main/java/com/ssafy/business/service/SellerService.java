package com.ssafy.business.service;


import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;
import com.ssafy.business.dto.responseDTO.SellerDetailDTO;

public interface SellerService {

    SellerDetailResponseDTO getSellerDetail(int sellerId);

    SellerDetailDTO getSellerFunding(int sellerId);

}
