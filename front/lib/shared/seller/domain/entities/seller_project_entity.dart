import 'package:equatable/equatable.dart';

/// 판매자의 프로젝트 정보를 표현하는 엔티티 클래스
class SellerProjectEntity extends Equatable {
  final int id;
  final String title;
  final String companyName;
  final String imageUrl;
  final double fundingPercentage;
  final String fundingAmount;
  final int remainingDays;
  final bool isActive; // 진행 중 여부

  const SellerProjectEntity({
    required this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.fundingPercentage,
    required this.fundingAmount,
    required this.remainingDays,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        companyName,
        imageUrl,
        fundingPercentage,
        fundingAmount,
        remainingDays,
        isActive,
      ];
}
