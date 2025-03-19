package com.ssafy.funding.mapper;

import com.ssafy.funding.entity.Funding;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;

@Mapper
public interface FundingMapper {
//    @Insert("""
//        INSERT INTO funding (seller_id, title, description, story_file_url, price, quantity, target_amount,
//                             current_amount, start_date, end_date, status, category, created_at, updated_at)
//        VALUES (#{sellerId}, #{title}, #{description}, #{storyFileUrl}, #{price}, #{quantity}, #{targetAmount},
//                #{currentAmount}, #{startDate}, #{endDate}, #{status}, #{category}, #{createdAt}, #{updatedAt})
//    """)
//    @Options(useGeneratedKeys = true, keyProperty = "fundingId")
    void createFunding(Funding funding);
}
