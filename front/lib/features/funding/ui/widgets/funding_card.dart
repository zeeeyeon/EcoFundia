import 'package:flutter/material.dart';
import '../../data/models/funding_model.dart';

class FundingCard extends StatelessWidget {
  final FundingModel funding;

  const FundingCard({super.key, required this.funding});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                funding.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              funding.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              funding.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (funding.currentAmount / funding.targetAmount)
                  .clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 5),
            Text(
              "현재 금액: ${funding.currentAmount}원 / 목표 금액: ${funding.targetAmount}원",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
