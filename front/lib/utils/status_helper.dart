import 'package:front/utils/funding_status.dart';

String getStatusLabel(FundingStatus status) {
  switch (status) {
    case FundingStatus.ongoing:
      return '진행중';
    case FundingStatus.success:
      return '성공';
    case FundingStatus.fail:
      return '실패';
  }
}
