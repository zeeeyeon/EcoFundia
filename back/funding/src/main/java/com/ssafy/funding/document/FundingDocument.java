package com.ssafy.funding.document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.CompletionField;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(indexName = "funding_index")
public class FundingDocument {

    @Id
    private Integer fundingId;

    private Integer sellerId;  // 판매자 ID

    @Field(type = FieldType.Text)
    private String title;      // 제목

    // 자동완성 기능을 위한 필드로, 검색 시 Completion Suggester가 사용됨
    @CompletionField(maxInputLength = 100)
    private String titleSuggest;

    @Field(type = FieldType.Text)
    private String description; // 설명

}
