import 'package:equatable/equatable.dart';
import 'package:front/features/home/domain/entities/project_entity.dart';

/// 결제 정보를 담는 Entity
class PaymentEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sellerName;
  final String imageUrl;
  final int price;
  final int quantity;
  final int couponDiscount;
  final int appliedCouponId; // 적용된 쿠폰 ID
  final String recipientName;
  final String address;
  final String phoneNumber;
  final bool isDefaultAddress;

  const PaymentEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sellerName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.couponDiscount = 0,
    this.appliedCouponId = 0, // 0은 쿠폰이 적용되지 않았음을 의미
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    this.isDefaultAddress = false,
  });

  // 총 상품 금액 계산
  int get totalProductPrice => price * quantity;

  // 최종 결제 금액 계산
  int get finalAmount => totalProductPrice - couponDiscount;

  // 쿠폰이 적용되었는지 확인
  bool get hasCouponApplied => appliedCouponId > 0 && couponDiscount > 0;

  PaymentEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sellerName,
    String? imageUrl,
    int? price,
    int? quantity,
    int? couponDiscount,
    int? appliedCouponId,
    String? recipientName,
    String? address,
    String? phoneNumber,
    bool? isDefaultAddress,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellerName: sellerName ?? this.sellerName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      appliedCouponId: appliedCouponId ?? this.appliedCouponId,
      recipientName: recipientName ?? this.recipientName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefaultAddress: isDefaultAddress ?? this.isDefaultAddress,
    );
  }

  /// 프로젝트 엔티티에서 결제 엔티티 생성 (상세 페이지에서 결제 페이지로 데이터 전달 용)
  factory PaymentEntity.fromProjectEntity(
    ProjectEntity project, {
    String recipientName = '',
    String address = '',
    String phoneNumber = '',
    bool isDefaultAddress = false,
    int quantity = 1,
    int couponDiscount = 0,
    int appliedCouponId = 0,
  }) {
    return PaymentEntity(
      id: 'PAYMENT_${DateTime.now().millisecondsSinceEpoch}',
      productId: project.id.toString(),
      productName: project.title,
      sellerName: project.sellerName,
      imageUrl: project.imageUrl,
      price: project.priceValue,
      quantity: quantity,
      couponDiscount: couponDiscount,
      appliedCouponId: appliedCouponId,
      recipientName: recipientName,
      address: address,
      phoneNumber: phoneNumber,
      isDefaultAddress: isDefaultAddress,
    );
  }

  @override
  List<Object> get props => [
        id,
        productId,
        productName,
        sellerName,
        imageUrl,
        price,
        quantity,
        couponDiscount,
        appliedCouponId,
        recipientName,
        address,
        phoneNumber,
        isDefaultAddress,
      ];
}
