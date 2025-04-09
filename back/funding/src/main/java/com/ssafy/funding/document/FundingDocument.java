package com.ssafy.funding.document;

import com.ssafy.funding.entity.enums.Category;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.CompletionField;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.annotations.InnerField;
import org.springframework.data.elasticsearch.annotations.MultiField;
import org.springframework.data.elasticsearch.annotations.DateFormat;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(indexName = "funding_index")
public class FundingDocument {

    @Id
    private Integer fundingId;

    private Integer sellerId;  // 판매자 ID

    // 멀티 필드를 사용해서 기본 Text와 정렬/집계용 Keyword 서브필드를 생성합니다.
    @MultiField(
            mainField = @Field(
                    type = FieldType.Text,
                    analyzer = "phonetic_analyzer",       // 인덱싱 시 발음 분석기를 적용
                    searchAnalyzer = "standard"            // 검색 시 표준 분석기를 사용 (또는 필요에 따라 phonetic_analyzer 사용)
            ),
            otherFields = {
                    @InnerField(suffix = "keyword", type = FieldType.Keyword)
            }
    )
    private String title;

    // 자동완성을 위한 필드 (Completion Suggester)
    @CompletionField(maxInputLength = 100)
    private String titleSuggest;

    @Field(type = FieldType.Text)
    private String description; // 설명

    // 이미지 URL (JSON 문자열 또는 다른 방식으로 저장 가능)
    @Field(type = FieldType.Keyword)
    private String imageUrl;

    // 종료 날짜
    @Field(type = FieldType.Date, format = DateFormat.date_hour_minute_second)
    private LocalDateTime endDate;



    // 현재 모금액
    @Field(type = FieldType.Integer)
    private Integer currentAmount;

    // 카테고리 (예: FASHION 등)
    @Field(type = FieldType.Keyword)
    private Category category;

    // 목표 달성률 또는 기타 비율
    @Field(type = FieldType.Integer)
    private Integer rate;
}
