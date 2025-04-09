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


@Service
@RequiredArgsConstructor
public class ElasticsearchService {

    private final FundingDocumentRepository repository;
    private final ElasticsearchOperations elasticsearchOperations;

    public void indexFunding(FundingDocument funding) {
        repository.save(funding);
    }

    public void deleteFunding(int fundingId) {
        repository.deleteById(fundingId);
    }

    public List<String> getSuggestions(String prefix) {
        Pageable pageable = PageRequest.of(0, 10);
        Criteria criteria = new Criteria("title").startsWith(prefix);
        CriteriaQuery query = new CriteriaQuery(criteria);
        query.setPageable(pageable);
        SearchHits<FundingDocument> searchHits = elasticsearchOperations.search(query, FundingDocument.class);
        return searchHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .distinct()
                .collect(Collectors.toList());
    }

    public List<String> advancedSuggestions(String prefix) {
        // 1. 기본 접두어 검색 결과
        List<String> prefixSuggestions = getSuggestions(prefix);
        Pageable pageable = PageRequest.of(0, 10);

        // 2. contains 조건을 사용한 유사 검색
        Criteria fuzzyCriteria = new Criteria("title").contains(prefix);
        CriteriaQuery fuzzyQuery = new CriteriaQuery(fuzzyCriteria);
        fuzzyQuery.setPageable(pageable);
        SearchHits<FundingDocument> fuzzyHits = elasticsearchOperations.search(fuzzyQuery, FundingDocument.class);
        List<String> fuzzySuggestions = fuzzyHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .collect(Collectors.toList());

        // 3. equals 조건을 사용한 정확한 단어 매칭 검색
        Criteria termCriteria = new Criteria("title").is(prefix);
        CriteriaQuery termQuery = new CriteriaQuery(termCriteria);
        termQuery.setPageable(pageable);
        SearchHits<FundingDocument> termHits = elasticsearchOperations.search(termQuery, FundingDocument.class);
        List<String> termSuggestions = termHits.getSearchHits().stream()
                .map(hit -> hit.getContent().getTitle())
                .collect(Collectors.toList());

        // 4. 세 검색 결과를 합치고 중복 제거
        List<String> advanced = new ArrayList<>();
        advanced.addAll(prefixSuggestions);
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
        Pageable pageable = PageRequest.of(page, size);

        // 제목 또는 설명에 keyword가 포함되는 조건
        Criteria criteria = new Criteria("title").contains(keyword)
                .or(new Criteria("description").contains(keyword));
        CriteriaQuery query = new CriteriaQuery(criteria);
        query.setPageable(pageable);

        // 정렬 옵션 추가: sort 값에 따라 실제 Elasticsearch 정렬 필드와 방향 결정
        if (sort != null && !sort.isEmpty()) {
            org.springframework.data.domain.Sort sortOption;
            switch (sort.toLowerCase()) {
                case "latest":
                    // 최신순: 종료 날짜(endDate)를 내림차순 정렬
                    sortOption = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "endDate");
                    break;
                case "oldest":
                    // 오래된 순: 종료 날짜를 오름차순 정렬
                    sortOption = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.ASC, "endDate");
                    break;
                case "popular":
                    // 인기순: rate 필드를 내림차순 정렬 (필요에 따라 currentAmount 등으로도 변경 가능)
                    sortOption = org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "rate");
                    break;
                default:
                    sortOption = org.springframework.data.domain.Sort.unsorted();
                    break;
            }
            query.addSort(sortOption);
        }

        SearchHits<FundingDocument> searchHits = elasticsearchOperations.search(query, FundingDocument.class);
        List<FundingDocument> docs = new ArrayList<>();
        searchHits.forEach(hit -> docs.add(hit.getContent()));
        return docs;
    }

}
