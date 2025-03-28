import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../view_model/funding_detail_view_model.dart';
import '../widgets/funding_detail_card.dart';

class FundingDetailScreen extends ConsumerWidget {
  final int fundingId;

  const FundingDetailScreen({super.key, required this.fundingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(fundingDetailProvider(fundingId));

    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        showHomeButton: true,
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('상세 정보 조회 중 오류 발생: $error')),
        data: (detail) => Padding(
          padding: const EdgeInsets.all(16),
          child: FundingDetailCard(detail: detail),
        ),
      ),
    );
  }
}
