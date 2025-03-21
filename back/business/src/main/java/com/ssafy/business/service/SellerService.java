package com.ssafy.business.service;


import com.ssafy.business.dto.responseDTO.SellerDetailResponseDTO;

public interface SellerService {

    SellerDetailResponseDTO getSellerDetail(int sellerId);

}
