import 'package:equatable/equatable.dart';

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
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    this.isDefaultAddress = false,
  });

  // 총 상품 금액 계산
  int get totalProductPrice => price * quantity;

  // 최종 결제 금액 계산
  int get finalAmount => totalProductPrice - couponDiscount;

  PaymentEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sellerName,
    String? imageUrl,
    int? price,
    int? quantity,
    int? couponDiscount,
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
      recipientName: recipientName ?? this.recipientName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefaultAddress: isDefaultAddress ?? this.isDefaultAddress,
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
        recipientName,
        address,
        phoneNumber,
        isDefaultAddress,
      ];
}
