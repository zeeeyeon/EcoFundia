import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/core/services/websocket_manager.dart';
import 'package:front/utils/logger_util.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 펀딩 금액 실시간 업데이트를 위한 WebSocket 서비스
class FundingWebSocketService {
  final WebSocketManager _webSocketManager;
  bool _isConnected = false;

  // 펀딩 금액 업데이트 콜백
  Function(int totalFund)? onTotalFundUpdated;

  FundingWebSocketService(this._webSocketManager);

  /// WebSocket 연결 시작
  Future<void> connect() async {
    if (_isConnected) {
      LoggerUtil.d('WebSocket 이미 연결되어 있음');
      return;
    }

    final token = await StorageService.getToken();
    if (token == null) {
      LoggerUtil.w('⚠️ WebSocket 연결 실패: 토큰 없음');
      return;
    }

    _webSocketManager.connect(
      userToken: token,
      onConnectCallback: _handleConnection,
      onError: _handleError,
    );
  }

  /// 연결 성공 시 호출되는 콜백
  void _handleConnection(StompFrame frame) {
    LoggerUtil.i('✅ 펀딩 WebSocket 연결 성공');
    _isConnected = true;
    _subscribeToFundingUpdates();
  }

  /// 에러 발생 시 호출되는 콜백
  void _handleError(dynamic error) {
    LoggerUtil.e('❌ 펀딩 WebSocket 연결 오류: $error');
    _isConnected = false;
  }

  /// 펀딩 업데이트 구독
  void _subscribeToFundingUpdates() {
    // 서버에서 지정한 토픽 주소를 사용
    const destination = '/topic/totalAmount';

    _webSocketManager.stompClient?.subscribe(
      destination: destination,
      callback: _handleFundingUpdate,
    );

    LoggerUtil.d('🔄 펀딩 업데이트 구독 시작: $destination');
  }

  /// 펀딩 업데이트 메시지 처리
  void _handleFundingUpdate(StompFrame frame) {
    LoggerUtil.d('📩 펀딩 업데이트 수신: ${frame.body}');

    try {
      if (frame.body == null) {
        LoggerUtil.w('⚠️ 빈 메시지 수신됨');
        return;
      }

      final data = jsonDecode(frame.body!);

      // API 응답 형식에 맞게 파싱
      final totalFund = _extractTotalFund(data);

      // 펀딩 금액이 0인 경우 무시 (유효하지 않은 업데이트로 간주)
      if (totalFund <= 0) {
        LoggerUtil.w('⚠️ 유효하지 않은 펀딩 금액 수신: $totalFund (0 이하의 값은 무시됨)');
        return;
      }

      LoggerUtil.i('💰 새로운 총 펀딩 금액: $totalFund');

      // 콜백 호출
      if (onTotalFundUpdated != null) {
        onTotalFundUpdated!(totalFund);
      }
    } catch (e) {
      LoggerUtil.e('❌ 펀딩 업데이트 파싱 오류: $e');
    }
  }

  /// 데이터에서 totalFund 값을 추출
  int _extractTotalFund(dynamic data) {
    try {
      // 디버그 로깅 추가
      LoggerUtil.d('🔍 펀딩 업데이트 데이터 파싱 시작: $data');

      // null 체크
      if (data == null) {
        LoggerUtil.w('⚠️ WebSocket 메시지가 null입니다.');
        return 0;
      }

      // 다양한 형태의 응답을 처리하기 위한 로직
      final content = data['content'] ?? data;

      LoggerUtil.d('🧩 추출된 content: $content');

      // content가 숫자인 경우 직접 반환
      if (content is int) {
        if (content <= 0) {
          LoggerUtil.w('⚠️ 서버에서 받은 펀딩 금액이 0 이하입니다: $content');
        }
        return content > 0 ? content : 0;
      }

      // content가 맵(객체)인 경우 필드 추출
      else if (content is Map) {
        // 다양한 필드명 지원 (API 변경 가능성 대비)
        final possibleFields = [
          'totalFund',
          'total_fund',
          'total',
          'amount',
          'totalAmount'
        ];

        // 가능한 필드 중 존재하는 첫 필드 사용
        String? foundField;
        dynamic fund;

        for (final field in possibleFields) {
          if (content.containsKey(field)) {
            foundField = field;
            fund = content[field];
            break;
          }
        }

        if (foundField != null) {
          LoggerUtil.d('📋 발견된 금액 필드: $foundField = $fund');
        } else {
          LoggerUtil.w('⚠️ 알려진 금액 필드를 찾을 수 없음: $content');
          return 0;
        }

        // 타입에 따른 변환
        if (fund is int) {
          return fund > 0 ? fund : 0;
        } else if (fund is String) {
          final parsed = int.tryParse(fund) ?? 0;
          return parsed > 0 ? parsed : 0;
        } else if (fund is double) {
          return fund > 0 ? fund.toInt() : 0;
        }
      }

      // content가 문자열인 경우 숫자로 변환 시도
      else if (content is String) {
        final parsed = int.tryParse(content) ?? 0;
        return parsed > 0 ? parsed : 0;
      }

      LoggerUtil.w('⚠️ 알 수 없는 응답 형식: $content');
      return 0;
    } catch (e) {
      LoggerUtil.e('❌ 펀딩 금액 추출 오류: $e');
      return 0;
    }
  }

  /// 연결 상태 확인
  bool get isConnected => _isConnected;

  /// 연결 종료
  void disconnect() {
    if (_isConnected) {
      _webSocketManager.disconnect();
      _isConnected = false;
      LoggerUtil.d('🔌 펀딩 WebSocket 연결 종료');
    }
  }
}

/// 펀딩 WebSocket 서비스 Provider
final fundingWebSocketServiceProvider =
    Provider<FundingWebSocketService>((ref) {
  final webSocketManager = ref.watch(websocketManagerProvider);
  return FundingWebSocketService(webSocketManager);
});
