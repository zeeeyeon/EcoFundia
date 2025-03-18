package com.ssafy.funding.entity.typeHandlers;

import com.ssafy.funding.entity.enums.Category;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(Category.class)
@MappedJdbcTypes(JdbcType.VARCHAR)
public class CategoryTypeHandler extends BaseTypeHandler<Category> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Category parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.name());
    }

    @Override
    public Category getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return null;
    }

    @Override
    public Category getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return null;
    }

    @Override
    public Category getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return null;
    }
}
