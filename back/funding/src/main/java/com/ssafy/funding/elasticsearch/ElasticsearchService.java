package com.ssafy.funding.elasticsearch;

import com.ssafy.funding.document.FundingDocument;
import com.ssafy.funding.entity.Funding;
import com.ssafy.funding.repository.FundingDocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.query.Criteria;
import org.springframework.data.elasticsearch.core.query.CriteriaQuery;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * ElasticsearchService 클래스
 * - Funding 엔티티를 Elasticsearch Document로 색인(index) 및 삭제(delete)합니다.
 * - CriteriaQuery를 사용하여 자동완성, 유사 검색, 그리고 용어 추천 기능을 구현합니다.
 */
@Service
@RequiredArgsConstructor
public class ElasticsearchService {

    private final FundingDocumentRepository repository;
    private final ElasticsearchOperations elasticsearchOperations;

    /**
     * Funding 엔티티를 FundingDocument로 변환하여 Elasticsearch에 색인(저장)합니다.
     *
     * @param funding DB의 Funding 엔티티
     */
    public void indexFunding(Funding funding) {
        FundingDocument doc = FundingDocument.builder()
                .fundingId(funding.getFundingId())
                .sellerId(funding.getSellerId())
                .title(funding.getTitle())
                .titleSuggest(funding.getTitle()) // 자동완성용 필드에 제목 값 할당
                .description(funding.getDescription())
                .build();
        repository.save(doc);
    }

    /**
     * 주어진 fundingId에 해당하는 Elasticsearch 문서를 삭제합니다.
     *
     * @param fundingId 삭제할 Funding의 ID
     */
    public void deleteFunding(int fundingId) {
        repository.deleteById(fundingId);
    }

    /**
     * 단순 접두어 검색 기반 자동완성 기능
     * CriteriaQuery를 사용하여 "title" 필드가 prefix로 시작하는 문서를 검색합니다.
     */
    public List<String> getSuggestions(String prefix) {
        Pageable pageable = PageRequest.of(0, 10);
        // Criteria: title이 prefix로 시작하는 조건
        Criteria criteria = new Criteria("title").startsWith(prefix);
        CriteriaQuery query = new CriteriaQuery(criteria);
        query.setPageable(pageable);
        SearchHits<FundingDocument> searchHits = elasticsearchOperations.search(query, FundingDocument.class);
        return searchHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .distinct()
                .collect(Collectors.toList());
    }

    /**
     * 고급 자동완성 기능: 접두어 검색 외에 유사 검색(Fuzzy)과 간단한 용어 추천(Term 기반)을 결합합니다.
     */
    public List<String> advancedSuggestions(String prefix) {
        // 접두어 검색 결과
        List<String> prefixSuggestions = getSuggestions(prefix);

        // 유사 검색: "title" 필드에 prefix가 포함되는 경우 (contains)
        Pageable pageable = PageRequest.of(0, 10);
        Criteria fuzzyCriteria = new Criteria("title").contains(prefix);
        CriteriaQuery fuzzyQuery = new CriteriaQuery(fuzzyCriteria);
        fuzzyQuery.setPageable(pageable);
        SearchHits<FundingDocument> fuzzyHits = elasticsearchOperations.search(fuzzyQuery, FundingDocument.class);
        List<String> fuzzySuggestions = fuzzyHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .collect(Collectors.toList());

        // 용어 추천: 간단한 Term 기반 검색 (정확한 단어 매칭을 위해 equals 조건 사용)
        Criteria termCriteria = new Criteria("title").is(prefix);
        CriteriaQuery termQuery = new CriteriaQuery(termCriteria);
        termQuery.setPageable(pageable);
        SearchHits<FundingDocument> termHits = elasticsearchOperations.search(termQuery, FundingDocument.class);
        List<String> termSuggestions = termHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .collect(Collectors.toList());

        // 세 결과를 합치고 중복 제거
        List<String> advanced = new ArrayList<>(prefixSuggestions);
        advanced.addAll(fuzzySuggestions);
        advanced.addAll(termSuggestions);
        return advanced.stream().distinct().collect(Collectors.toList());
    }

    /**
     * 검색 기능: 주어진 keyword를 기반으로 제목이나 설명에 대해 검색을 수행합니다.
     * CriteriaQuery를 사용하며, 페이지네이션 및 정렬 옵션을 지원합니다.
     *
     * @param keyword 검색어
     * @param sort    정렬 기준 필드 (예: "title")
     * @param page    페이지 번호 (1부터 시작)
     * @param size    한 페이지당 결과 수
     * @return 검색 결과 FundingDocument 리스트
     */
    public List<FundingDocument> searchDocuments(String keyword, String sort, int page, int size) {
        Pageable pageable = PageRequest.of(page - 1, size);
        // 제목 또는 설명에 keyword가 포함되는 조건
        Criteria criteria = new Criteria("title").contains(keyword)
                .or(new Criteria("description").contains(keyword));
        CriteriaQuery query = new CriteriaQuery(criteria);
        query.setPageable(pageable);
        // 정렬 옵션 추가 (Sort.by() 사용)
        if (sort != null && !sort.isEmpty()) {
            query.addSort(org.springframework.data.domain.Sort.by(sort));
        }
        SearchHits<FundingDocument> searchHits = elasticsearchOperations.search(query, FundingDocument.class);
        List<FundingDocument> docs = new ArrayList<>();
        searchHits.forEach(hit -> docs.add(hit.getContent()));
        return docs;
    }
}
