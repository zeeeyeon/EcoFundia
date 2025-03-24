String getStatusLabel(String status) {
  switch (status) {
    case 'ONGOING':
      return '진행중';
    case 'SUCCESS':
      return '종료';
    default:
      return '기타';
  }
}
