package com.ssafy.user.mapper;

import com.ssafy.user.entity.RefreshToken;
import com.ssafy.user.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface UserMapper {

    User findByEmail(@Param("email") String email);

    User findById(@Param("userId") int userId);

    void insertUser(User user);

    void updateMyInfo(@Param("userId") int userId, @Param("nickname") String nickname, @Param("account") String account);

    String findNicknameById(@Param("userId") int userId);
}
