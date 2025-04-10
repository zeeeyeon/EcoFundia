import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/providers/websocket_provider.dart';
import 'package:front/core/services/storage_service.dart';
import 'package:front/core/services/websocket_manager.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/features/chat/data/models/chat_model.dart';
import 'package:front/features/chat/ui/view_model/chat_view_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int fundingId;
  final String fundingTitle;

  const ChatRoomScreen({
    super.key,
    required this.fundingId,
    required this.fundingTitle,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final WebSocketManager _wsManager;
  late final ChatRoomViewModel _viewModel;
  int? _userId;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _wsManager = ref.read(websocketManagerProvider);
    _viewModel = ref.read(chatRoomViewModelProvider(widget.fundingId).notifier);

    // 전체 초기화
    Future.microtask(() async {
      await _initializeChatRoom();
      await _viewModel.fetchMessages();
      _scrollToBottom();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 50) {
          _viewModel.fetchMoreMessages();
        }
      });
    });
  }

  Future<void> _initializeChatRoom() async {
    try {
      final token = await StorageService.getToken();
      final userIdStr = await StorageService.getUserId();

      if (token == null || userIdStr == null) return;

      _userId = int.tryParse(userIdStr);
      if (_userId == null) return;

      if (!_wsManager.isConnected) {
        _wsManager.connect(
          userToken: token,
          onConnectCallback: (_) {
            if (!mounted) return;

            debugPrint('✅ WebSocket 연결 완료됨! 채팅방 구독 시작');

            _subscribe();
          },
          onError: (error) {
            debugPrint('❌ WebSocket 연결 오류: $error');
          },
        );
      } else {
        _subscribe();
      }
    } catch (e) {
      debugPrint('❌ 초기화 오류: $e');
    }
  }

  void _subscribe() {
    if (_userId == null) return;

    final destination = '/sub/chat/${widget.fundingId}';
    debugPrint('📡 채팅방 구독 요청 → $destination (userId: $_userId)');

    _wsManager.subscribeToRoom(
      fundingId: widget.fundingId,
      userId: _userId!,
      onMessage: (StompFrame frame) {
        debugPrint('📥 [onMessage] 수신됨: ${frame.body}');
        if (!mounted || frame.body == null) return;

        try {
          final data = jsonDecode(frame.body!);
          final newMessage = ChatMessage.fromJson(data);
          _viewModel.addMessage(newMessage);
        } catch (e) {
          debugPrint('❌ JSON 파싱 오류: $e');
        }
      },
    );
    _isSubscribed = true; // ✅ 구독 완료 처리
  }

  void _sendMessage() async {
    if (!_isSubscribed) {
      debugPrint('⛔ 아직 구독되지 않았으므로 메시지 전송 차단');
      return;
    }
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null || !_wsManager.isConnected) return;
    final nickname = await StorageService.getNickname();

    _wsManager.sendMessageToRoom(
      fundingId: widget.fundingId,
      senderId: _userId!,
      nickname: nickname ?? '익명',
      content: text,
      createdAt: DateTime.now(),
    );

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    // WebSocket 구독 해지
    // WebSocketManager에 해당 기능이 구현되어 있어야 함
    if (_isSubscribed) {
      // 구독된 경우에만 해지 시도
      try {
        _wsManager.unsubscribeFromRoom(widget.fundingId); // fundingId 전달
        debugPrint('🔌 채팅방 구독 해지 완료: /sub/chat/${widget.fundingId}');
        _isSubscribed = false; // 구독 상태 업데이트
      } catch (e) {
        debugPrint('❌ 채팅방 구독 해지 중 오류: $e');
      }
    }

    // 메시지 클리어 (ViewModel의 autoDispose에 맡김)
    // Future.microtask(() {
    //   ref.read(chatRoomViewModelProvider(widget.fundingId).notifier).clearMessages();
    // });

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatRoomViewModelProvider(widget.fundingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅방: ${widget.fundingTitle} (#${widget.fundingId})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final fromMe = msg.senderId == _userId;
                final formattedTime =
                    TimeOfDay.fromDateTime(msg.createdAt).format(context);

                return Align(
                  alignment:
                      fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: fromMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!fromMe && msg.nickname.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            msg.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: fromMe
                              ? AppColors.primary.withOpacity(0.9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(fromMe ? 12 : 0),
                            bottomRight: Radius.circular(fromMe ? 0 : 12),
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: fromMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 2, left: 8, right: 8),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
