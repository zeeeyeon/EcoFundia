import 'package:equatable/equatable.dart';
import 'package:front/shared/payment/domain/entities/payment_entity.dart';

/// 결제 정보 DTO (Data Transfer Object)
class PaymentDTO extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sellerName;
  final String imageUrl;
  final int price;
  final int quantity;
  final int couponDiscount;
  final int appliedCouponId;
  final String recipientName;
  final String address;
  final String phoneNumber;
  final bool isDefaultAddress;

  const PaymentDTO({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sellerName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.couponDiscount = 0,
    this.appliedCouponId = 0,
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    this.isDefaultAddress = false,
  });

  // 총 상품 금액 계산
  int get totalProductPrice => price * quantity;

  // 최종 결제 금액 계산
  int get finalAmount => totalProductPrice - couponDiscount;

  /// JSON에서 PaymentDTO 생성
  factory PaymentDTO.fromJson(Map<String, dynamic> json) {
    return PaymentDTO(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      sellerName: json['sellerName'] as String,
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as int,
      quantity: json['quantity'] as int,
      couponDiscount: json['couponDiscount'] as int? ?? 0,
      appliedCouponId: json['appliedCouponId'] as int? ?? 0,
      recipientName: json['recipientName'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isDefaultAddress: json['isDefaultAddress'] as bool? ?? false,
    );
  }

  /// PaymentDTO를 Entity로 변환
  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      productId: productId,
      productName: productName,
      sellerName: sellerName,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      couponDiscount: couponDiscount,
      appliedCouponId: appliedCouponId,
      recipientName: recipientName,
      address: address,
      phoneNumber: phoneNumber,
      isDefaultAddress: isDefaultAddress,
    );
  }

  /// PaymentDTO를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sellerName': sellerName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'couponDiscount': couponDiscount,
      'appliedCouponId': appliedCouponId,
      'recipientName': recipientName,
      'address': address,
      'phoneNumber': phoneNumber,
      'isDefaultAddress': isDefaultAddress,
    };
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
