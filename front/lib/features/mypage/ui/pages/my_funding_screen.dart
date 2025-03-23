import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/my_funding_view_model.dart';

class MyFundingScreen extends ConsumerWidget {
  const MyFundingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myFundingsState = ref.watch(myFundingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 펀딩 목록'),
      ),
      body: myFundingsState.when(
        data: (fundings) => ListView.builder(
          itemCount: fundings.length,
          itemBuilder: (context, index) {
            final funding = fundings[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Image.network(
                  funding.imageUrls.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(funding.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(funding.description),
                    const SizedBox(height: 4),
                    Text('달성률: ${funding.rate}%, 후원금액: ${funding.totalPrice}원'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('에러 발생: $err')),
      ),
    );
  }
}
