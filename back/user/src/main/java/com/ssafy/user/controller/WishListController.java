package com.ssafy.user.controller;

import com.ssafy.user.common.response.Response;
import com.ssafy.user.common.response.PageResponse;
import com.ssafy.user.dto.response.WishiListResponseDto;
import com.ssafy.user.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.ssafy.user.common.response.ResponseCode.*;

@RestController
@RequestMapping("/api/user/wishList")
@RequiredArgsConstructor
public class WishListController {

    private final WishListService wishListService;

    @PostMapping("/{fundingId}")
    public ResponseEntity<?> createWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.createWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(CREATE_WISHLIST, null), CREATE_WISHLIST.getHttpStatus());
    }

    @GetMapping("/ongoing")
    public ResponseEntity<?> getMyWishList(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        PageResponse<WishiListResponseDto> result = wishListService.getWishList(userId, page, size);
        return new ResponseEntity<>(Response.create(GET_WISHLIST, result), GET_WISHLIST.getHttpStatus());
    }

    @GetMapping("/done")
    public ResponseEntity<?> getDoneMyWishList(
            @RequestHeader("X-User-Id") int userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        PageResponse<WishiListResponseDto> result = wishListService.getDoneWishList(userId, page, size);
        return new ResponseEntity<>(Response.create(GET_WISHLIST, result), GET_WISHLIST.getHttpStatus());
    }

    @DeleteMapping("/{fundingId}")
    public ResponseEntity<?> deleteWish(@RequestHeader("X-User-Id") int userId, @PathVariable int fundingId) {
        wishListService.deleteWish(userId, fundingId);
        return new ResponseEntity<>(Response.create(DELETE_WISHLIST, null), DELETE_WISHLIST.getHttpStatus());
    }
}
