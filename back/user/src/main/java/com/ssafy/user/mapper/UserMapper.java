package com.ssafy.user.mapper;

import com.ssafy.user.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {

    User findByEmail(String email);

    int isSeller(int userId);

    void insertUser(User user);
}
