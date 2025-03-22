import 'package:front/shared/seller/domain/entities/seller_entity.dart';
import 'package:front/shared/seller/domain/repositories/seller_repository.dart';

/// 판매자 상세 정보 조회 UseCase
class GetSellerDetailsUseCase {
  final SellerRepository repository;

  GetSellerDetailsUseCase(this.repository);

  Future<SellerEntity> execute(int sellerId) async {
    return await repository.getSellerDetails(sellerId);
  }
}
