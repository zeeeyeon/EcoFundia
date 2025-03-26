package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.dto.funding.response.UserWishlistFundingDto;
import com.ssafy.funding.entity.WishList;
import com.ssafy.funding.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/wishList")
@RequiredArgsConstructor
public class WishListController {

    private final WishListService wishListService;

    @PostMapping("/{fundingId}")
    public ResponseEntity<?> createWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.createWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(CREATE_WISHLIST, null), CREATE_WISHLIST.getHttpStatus());
    }

    @GetMapping("/ongoing")
    public List<UserWishlistFundingDto> getOngoingWishlist(@RequestHeader("X-User-Id") int userId) {
        return wishListService.getOngoingWishlist(userId);
    }

    @GetMapping("/done")
    public List<UserWishlistFundingDto> getDoneWishlist(@RequestHeader("X-User-Id") int userId) {
        return wishListService.getDoneWishlist(userId);
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.deleteWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(DELETE_WISHLIST, null), DELETE_WISHLIST.getHttpStatus());
    }
}
