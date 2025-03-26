import 'package:front/shared/payment/data/models/payment_dto.dart';

/// 결제 더미 데이터
const paymentDummy = PaymentDTO(
  id: 'PAYMENT_1',
  productId: 'PRODUCT_1',
  productName: '프리미엄 딸기 세트',
  sellerName: '달콤농장',
  imageUrl: 'https://example.com/strawberry.jpg',
  price: 35000,
  quantity: 1,
  couponDiscount: 0,
  recipientName: '홍길동',
  address: '서울특별시 강남구 테헤란로 123 456동 789호',
  phoneNumber: '010-1234-5678',
  isDefaultAddress: true,
);
