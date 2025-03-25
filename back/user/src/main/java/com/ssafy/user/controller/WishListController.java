package com.ssafy.user.controller;

import com.ssafy.user.common.response.Response;
import com.ssafy.user.entity.WishList;
import com.ssafy.user.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.ssafy.user.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user/wishlist")
@RequiredArgsConstructor
public class WishListController {

    private final WishListService wishListService;

    @PostMapping("/{fundingId}")
    public ResponseEntity<?> createWish(@RequestHeader("X-User-Id") String userId, @PathVariable int fundingId) {
        wishListService.createWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(CREATE_WISHLIST, null), CREATE_WISHLIST.getHttpStatus());
    }

    @GetMapping("/onging")
    public ResponseEntity<?> getMyWishList(@RequestHeader("X-User-Id") String userId) {
        List<WishList> list = wishListService.getWishList(userId);
        return new ResponseEntity<>(Response.create(GET_WISHLIST, list), GET_WISHLIST.getHttpStatus());
    }

    @GetMapping("/done")
    public ResponseEntity<?> getDoneMyWishList(@RequestHeader("X-User-Id") String userId) {
        List<WishList> list = wishListService.getDoneWishList(userId);
        return new ResponseEntity<>(Response.create(GET_WISHLIST, list), GET_WISHLIST.getHttpStatus());
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") String userId, @PathVariable int fundingId) {
        wishListService.deleteWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(DELETE_WISHLIST, null), DELETE_WISHLIST.getHttpStatus());
    }
}