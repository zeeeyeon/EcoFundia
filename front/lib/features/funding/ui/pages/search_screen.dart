import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/ui/widgets/custom_app_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        showSearchField: true,
        isSearchEnabled: true,
        searchController: _searchController,
        onSearchChanged: (value) {
          // debounce 검색 처리
        },
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // 🏷️ 필터 버튼들 (베스트펀딩, 마감임박 등)
              Wrap(
                spacing: 8,
                children: [
                  _CategoryChip(label: "🏆 베스트펀딩"),
                  _CategoryChip(label: "⏰ 마감임박"),
                  _CategoryChip(label: "# 오늘의 검색어"),
                ],
              ),

              SizedBox(height: 24),

              Text(
                '인기 검색어 🔥',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),

              // 🔥 인기 검색어 목록
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PopularKeyword(rank: 1, keyword: "토마토"),
                  _PopularKeyword(rank: 2, keyword: "이지연"),
                  _PopularKeyword(rank: 3, keyword: "도경원"),
                  _PopularKeyword(rank: 4, keyword: "박수민"),
                ],
              ),

              Spacer(),

              Center(
                child: Text(
                  'SIMPLE하게, 지구를 위한 작은 실천의 시작 🌱',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 필터용 카테고리 칩
class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFF1F1F1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

// 인기 검색어 아이템
class _PopularKeyword extends StatelessWidget {
  final int rank;
  final String keyword;

  const _PopularKeyword({required this.rank, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rank ',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: keyword,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
