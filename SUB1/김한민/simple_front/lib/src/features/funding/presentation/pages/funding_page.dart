import 'package:flutter/material.dart';

class FundingPage extends StatelessWidget {
  const FundingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('펀딩'),
      ),
      body: const Center(
        child: Text(
          'Funding Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
