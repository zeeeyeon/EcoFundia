package com.ssafy.funding.controller;

import com.ssafy.funding.common.response.Response;
import com.ssafy.funding.entity.WishList;
import com.ssafy.funding.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.ssafy.funding.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
public class WishListController {

    private final WishListService wishListService;

    @PostMapping("/{fundingId}")
    public ResponseEntity<?> createWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.createWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(CREATE_WISHLIST, null), CREATE_WISHLIST.getHttpStatus());
    }

    @GetMapping
    public ResponseEntity<?> getMyWishlist(@RequestHeader("X-User-Id") int userId) {
//        List<WishList> list = wishListService.getWishList(userId);
//        return new ResponseEntity<>(Response.create(GET_WISHLIST, list), GET_WISHLIST.getHttpStatus());
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.deleteWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(DELETE_WISHLIST, null), DELETE_WISHLIST.getHttpStatus());
    }
}
