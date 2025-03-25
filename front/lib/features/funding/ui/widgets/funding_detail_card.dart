import 'package:flutter/material.dart';
import '../../data/models/funding_model.dart';

class FundingDetailCard extends StatelessWidget {
  final FundingModel funding;

  const FundingDetailCard({super.key, required this.funding});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            funding.imageUrls.first,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: const Color.fromRGBO(158, 158, 158, 0.3),
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          funding.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          funding.description,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Text(
          "목표 금액: ${funding.targetAmount}원",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "현재 금액: ${funding.currentAmount}원",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (funding.currentAmount / funding.targetAmount).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
      ],
    );
  }
}
