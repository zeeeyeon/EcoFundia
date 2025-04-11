package com.ssafy.user.mapper;

import com.ssafy.user.dto.request.GetAgeListRequestDto;
import com.ssafy.user.entity.RefreshToken;
import com.ssafy.user.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface UserMapper {

    User findByEmail(@Param("email") String email);

    User findById(@Param("userId") int userId);

    void insertUser(User user);

    void updateMyInfo(@Param("userId") int userId, @Param("nickname") String nickname, @Param("account") String account);

    String findNicknameById(@Param("userId") int userId);

    List<Map<String, Object>> selectAgeGroupCounts(@Param("list") List<GetAgeListRequestDto> dtos);

    List<User> getSellerFundingDetailOrderList(@Param("userIdList") List<Integer> userIdList);
}
