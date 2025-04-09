import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:front/utils/logger_util.dart'; // LoggerUtil 추가 가정

/// WebSocket 연결 및 채팅 구독/메시지 전송을 담당하는 매니저 클래스
class WebSocketManager {
  StompClient? _stompClient; // 변수명 통일 및 private 처리
  bool _isConnected = false;

  StompClient? get stompClient => _stompClient;

  /// 연결 상태 변경 시 호출될 콜백 함수
  Function(bool isConnected)? onConnectionStatusChanged;

  /// 현재 WebSocket 연결 여부
  bool get isConnected => _isConnected;

  /// 연결 상태 설정 (내부용). 상태 변경 시 콜백 호출
  set _connected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      // 콜백 함수가 설정되어 있으면 호출
      onConnectionStatusChanged?.call(_isConnected);
    }
  }

  /// 구독 상태 관리: fundingId 기준으로 Unsubscribe 함수 저장 (중복 구독 방지 및 해제용)
  final Map<int, StompUnsubscribe> _unsubscribeMap = {};

  /// WebSocket 연결 시작
  void connect({
    String? userToken, // 인증 토큰
    required void Function(StompFrame frame) onConnectCallback, // 연결 성공 시 콜백
    void Function(dynamic error)? onError, // 웹소켓 에러 시 콜백
  }) {
    // 이미 연결된 상태면 중복 연결 방지
    if (_stompClient != null && _stompClient!.connected) {
      LoggerUtil.i('✅ 이미 WebSocket에 연결되어 있습니다.');
      onConnectCallback(
          StompFrame(command: 'CONNECTED')); // 이미 연결되었음을 알리기 위해 콜백 호출
      return;
    }

    // 헤더 설정 (토큰이 있는 경우에만 인증 헤더 추가)
    Map<String, String> connectHeaders = {};
    Map<String, String> stompHeaders = {};

    if (userToken != null && userToken.isNotEmpty) {
      connectHeaders['Authorization'] = 'Bearer $userToken';
      stompHeaders['Authorization'] = 'Bearer $userToken';
    }

    _stompClient = StompClient(
        config: StompConfig(
      url:
          'wss://j12e206.p.ssafy.io/ws-stomp', // ✅ WebSocket 엔드포인트 (StompConfig 표준 URL 형식)
      onConnect: (frame) {
        _connected = true; // 연결 상태 업데이트 (setter 통해 콜백 트리거)
        LoggerUtil.i('✅ WebSocket 연결 성공');
        onConnectCallback(frame);
      },
      onWebSocketError: (error) {
        _connected = false; // 연결 상태 업데이트
        // onError 콜백이 제공되면 호출, 아니면 기본 로그 출력
        if (onError != null) {
          onError(error);
        } else {
          LoggerUtil.e('❌ WebSocket 연결 오류: $error');
        }
      },
      onDisconnect: (frame) {
        _connected = false; // 연결 상태 업데이트
        LoggerUtil.i('🔌 WebSocket 연결 해제됨');
      },
      onStompError: (frame) {
        _connected = false; // 연결 상태 업데이트
        LoggerUtil.e('⚠️ STOMP 프로토콜 오류: ${frame.body}');
      },
      beforeConnect: () async {
        LoggerUtil.i('🔌 WebSocket 연결 시도 중...');
        await Future.delayed(const Duration(milliseconds: 200));
      },
      stompConnectHeaders: stompHeaders, // STOMP 프로토콜 레벨 헤더
      webSocketConnectHeaders: connectHeaders, // WebSocket 핸드셰이크 레벨 헤더
      // 연결 안정성을 위해 heartbeat 설정 (5초 권장)
      heartbeatIncoming: const Duration(seconds: 5),
      heartbeatOutgoing: const Duration(seconds: 5),
    ));

    _stompClient!.activate(); // 클라이언트 활성화 (연결 시작)
  }

  /// 채팅방(fundingId) 구독
  /// 중복 구독을 방지하고, 기존 구독이 있으면 해제 후 새로 구독합니다.
  void subscribeToRoom({
    required int fundingId,
    required int userId, // 구독 시 사용자 ID 전달 (서버 요구사항에 따라)
    required void Function(StompFrame frame) onMessage, // 메시지 수신 시 콜백
  }) {
    // 연결 상태 확인
    if (_stompClient == null || !_isConnected) {
      LoggerUtil.w(
          '❌ STOMP 클라이언트가 연결되지 않았습니다. 구독을 건너뜁니다: /sub/chat/$fundingId');
      return;
    }

    final destination = '/sub/chat/$fundingId'; // STOMP 표준 구독 경로

    // ✅ 기존 구독이 있다면 해제 후 새로 등록하여 중복 구독 방지
    if (_unsubscribeMap.containsKey(fundingId)) {
      LoggerUtil.i('🔁 기존 채팅방 구독 해제 시도: $destination');
      try {
        _unsubscribeMap[fundingId]?.call(); // 기존 구독 해제 함수 호출
      } catch (e) {
        LoggerUtil.e('🔁 기존 구독 해제 중 오류 발생:', e);
      }
      _unsubscribeMap.remove(fundingId); // 맵에서 제거
    }

    // 📨 구독 요청
    try {
      LoggerUtil.i('📨 채팅방 구독 시도: $destination, 유저: $userId');
      final unsubscribe = _stompClient!.subscribe(
        destination: destination,
        headers: {
          'userId': userId.toString(), // 헤더에 사용자 ID 추가
          // 'id': 'sub-${DateTime.now().millisecondsSinceEpoch}' // 필요시 고유 구독 ID 추가 가능
        },
        callback: (frame) {
          LoggerUtil.d('📥 메시지 수신됨 from server');
          print('📥 메시지 수신됨 from server');
          LoggerUtil.d('📝 수신 데이터: ${frame.body}');
          print('📝 수신 데이터: ${frame.body}');
          onMessage(frame);
        },
        // 메시지 수신 콜백 지정
      );
      // 구독 해제 함수를 맵에 저장
      _unsubscribeMap[fundingId] = unsubscribe;
      LoggerUtil.i('✅ 채팅방 구독 성공: $destination');
      print('✅ 채팅방 구독 성공: $destination');
    } catch (e) {
      LoggerUtil.e('❌ 채팅방 구독 중 오류 발생 ($destination):', e);
      print('❌ 채팅방 구독 중 오류 발생 ($destination):');
    }
  }

  /// 특정 채팅방으로 메시지 전송
  void sendMessageToRoom({
    required int fundingId,
    required int senderId,
    required String nickname,
    required String content,
    DateTime? createdAt,
  }) {
    if (_stompClient == null || !_isConnected) {
      LoggerUtil.w('❌ 메시지 전송 실패 - STOMP 미연결 상태');
      print('❌ 메시지 전송 실패 - STOMP 미연결 상태');
      return;
    }

    final destination = '/pub/chat/$fundingId';

    final message = {
      'fundingId': fundingId,
      'senderId': senderId,
      'nickname': nickname,
      'content': content,
      if (createdAt != null) 'createdAt': createdAt.toIso8601String(),
    };

    try {
      LoggerUtil.d('📤 메시지 전송 시작 → $destination');
      print('📤 메시지 전송 시작 → $destination');
      LoggerUtil.d('📝 전송 내용: ${jsonEncode(message)}');
      print('📝 전송 내용: ${jsonEncode(message)}');
      _stompClient!.send(
        destination: destination,
        body: jsonEncode(message),
        headers: {'content-type': 'application/json'},
      );
      LoggerUtil.d('📤 메시지 전송 완료');
      print('📤 메시지 전송 완료');
    } catch (e) {
      LoggerUtil.e('❌ 메시지 전송 실패: $e');
      print('❌ 메시지 전송 실패: $e');
    }
  }

  /// 일반적인 STOMP 구독 (채팅방 외 다른 용도)
  /// 이 메소드는 구독 해제를 자동으로 관리하지 않습니다. 필요시 별도 관리가 필요합니다.
  StompUnsubscribe? safeSubscribe({
    required String destination,
    required void Function(StompFrame frame) callback,
    Map<String, String>? headers,
  }) {
    // 연결 상태 확인
    if (_stompClient == null || !_isConnected) {
      LoggerUtil.w('❌ WebSocket이 연결되지 않았습니다. 일반 구독을 건너뜁니다: $destination');
      return null;
    }

    try {
      LoggerUtil.i('📩 일반 WebSocket 구독 시도: $destination');
      final unsubscribe = _stompClient!.subscribe(
        destination: destination,
        callback: callback,
        headers: headers ?? {}, // 헤더가 없으면 빈 맵 전달
      );
      LoggerUtil.i('✅ 일반 WebSocket 구독 성공: $destination');
      return unsubscribe; // 구독 해제 함수 반환
    } catch (e) {
      LoggerUtil.e('❌ 일반 WebSocket 구독 중 오류 발생 ($destination):', e);
      return null;
    }
  }

  /// 모든 구독 해제 및 WebSocket 연결 종료
  void disconnect() {
    LoggerUtil.i('🔌 WebSocket 연결 해제 시도 중...');
    if (_stompClient == null) {
      LoggerUtil.w('🔌 이미 연결이 해제되었거나 초기화되지 않았습니다.');
      return;
    }

    // 저장된 모든 구독 해제
    if (_unsubscribeMap.isNotEmpty) {
      LoggerUtil.d('   - 저장된 구독 (${_unsubscribeMap.length}개) 해제 시도...');
      _unsubscribeMap.forEach((fundingId, unsubscribe) {
        try {
          LoggerUtil.d('     - 구독 해제: /sub/chat/$fundingId');
          unsubscribe.call();
        } catch (e) {
          LoggerUtil.e('     - 구독 해제 중 오류 발생 (/sub/chat/$fundingId):', e);
        }
      });
      _unsubscribeMap.clear(); // 구독 맵 비우기
      LoggerUtil.d('   - 구독 맵 정리 완료.');
    }

    // STOMP 클라이언트 비활성화 (연결 종료)
    try {
      _stompClient?.deactivate();
      LoggerUtil.d('   - StompClient 비활성화 완료.');
    } catch (e) {
      LoggerUtil.e('   - StompClient 비활성화 중 오류 발생:', e);
    }

    _stompClient = null; // 클라이언트 참조 제거
    _connected = false; // 연결 상태 업데이트 (setter 통해 콜백 트리거)
    LoggerUtil.i('🔌 WebSocket 연결 해제 완료.');
  }
}
