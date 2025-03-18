package com.ssafy.funding.entity.typeHandlers;

import com.ssafy.funding.entity.enums.Status;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(Status.class)
@MappedJdbcTypes(JdbcType.VARCHAR)
public class StatusTypeHandler extends BaseTypeHandler<Status> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Status parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.name());
    }

    @Override
    public Status getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return null;
    }

    @Override
    public Status getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return null;
    }

    @Override
    public Status getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return null;
    }
}
