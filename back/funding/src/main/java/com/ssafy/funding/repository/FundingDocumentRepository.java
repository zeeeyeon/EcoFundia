package com.ssafy.funding.repository;

import com.ssafy.funding.document.FundingDocument;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FundingDocumentRepository extends ElasticsearchRepository<FundingDocument, Integer> {
    // 기본 CRUD 메소드(save, findById, delete 등)를 사용할 수 있습니다.
}
