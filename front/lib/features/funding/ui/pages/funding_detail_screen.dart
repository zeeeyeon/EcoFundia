import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../data/models/funding_model.dart';
import '../widgets/funding_detail_card.dart';

class FundingDetailScreen extends StatelessWidget {
  final FundingModel funding;

  const FundingDetailScreen({super.key, required this.funding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        showHomeButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FundingDetailCard(funding: funding),
      ),
    );
  }
}
