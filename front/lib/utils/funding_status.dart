enum FundingStatus { ongoing, success, fail }

FundingStatus parseFundingStatus(String value) {
  switch (value.toUpperCase()) {
    case 'ONGOING':
      return FundingStatus.ongoing;
    case 'SUCCESS':
      return FundingStatus.success;
    case 'FAIL':
      return FundingStatus.fail;
    default:
      return FundingStatus.ongoing;
  }
}

bool isOngoing(FundingStatus status) => status == FundingStatus.ongoing;
bool isSuccess(FundingStatus status) => status == FundingStatus.success;
