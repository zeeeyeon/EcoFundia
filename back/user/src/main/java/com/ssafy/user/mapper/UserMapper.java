package com.ssafy.user.mapper;

import com.ssafy.user.entity.RefreshToken;
import com.ssafy.user.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface UserMapper {

    User findByEmail(String email);

    void insertUser(User user);

    void insertRefreshToken(@Param("userId") int userId,
                            @Param("refreshToken") String refreshToken,
                            @Param("issuedAt") LocalDateTime issuedAt,
                            @Param("expiresAt") LocalDateTime expiresAt);

    List<RefreshToken> findRefreshTokensByUserId(int userId);

    void deleteRefreshTokenById(@Param("id") int id);

    int updateMyInfo(@Param("email") String email, @Param("nickname") String nickname, @Param("account") String account);
}
