import 'package:cuutrobaolu/presentation/features/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Thông tin thu thập được (nếu có)

          // _buildInfoHeader(),

          // Danh sách tin nhắn
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return _buildMessagesList();
            }),
          ),

          // Input tin nhắn
          _buildMessageInput(),
        ],
      ),

      // Floating Action Button cho location
      // floatingActionButton: Obx(() {
      //   if (_controller.currentPosition.value != null) {
      //     return FloatingActionButton.small(
      //       onPressed: _controller.showCollectedInfo,
      //       backgroundColor: Colors.green,
      //       child: const Icon(Icons.info_outline, color: Colors.white),
      //       tooltip: 'Xem thông tin đã thu thập',
      //     );
      //   }
      //   return const SizedBox.shrink();
      // }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Trợ lý cứu trợ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Obx(() => Text(
            _controller.isComplete.value
                ? '✅ Đã đủ thông tin'
                : 'Đang thu thập thông tin...',
            style: const TextStyle(fontSize: 12),
          )),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (_controller.messages.length > 1) {
            _showExitConfirmation();
          } else {
            Get.back();
          }
        },
      ),
      actions: [
        Obx(() => IconButton(
          icon: Icon(
            _controller.currentPosition.value != null
                ? Icons.location_on
                : Icons.location_off,
            color: _controller.currentPosition.value != null
                ? Colors.green
                : Colors.orange,
          ),
          onPressed: _controller.refreshLocation,
          tooltip: _controller.currentPosition.value != null
              ? 'Vị trí đã xác định\n${_controller.currentAddress.value}'
              : 'Chạm để lấy vị trí',
        )),
      ],
    );
  }

  Widget _buildInfoHeader() {
    return Obx(() {
      final collectedInfo = _controller.collectedInfo;
      final hasInfo = collectedInfo['type'].toString().isNotEmpty ||
          collectedInfo['title'].toString().isNotEmpty ||
          collectedInfo['description'].toString().isNotEmpty ||
          collectedInfo['contact'].toString().isNotEmpty;

      if (!hasInfo) return const SizedBox();

      final isInfoComplete = collectedInfo['type'].toString().isNotEmpty &&
          collectedInfo['title'].toString().isNotEmpty &&
          collectedInfo['description'].toString().isNotEmpty &&
          collectedInfo['contact'].toString().isNotEmpty;

      return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đã thu thập:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCollectedInfoSummary(collectedInfo),
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isInfoComplete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'ĐỦ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  String _getCollectedInfoSummary(Map<String, dynamic> info) {
    final List<String> parts = [];

    if (info['type'].toString().isNotEmpty) {
      parts.add('Loại: ${info['type']}');
    }
    if (info['title'].toString().isNotEmpty) {
      parts.add('Tiêu đề: ${info['title']}');
    }

    return parts.join(' • ');
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      padding: const EdgeInsets.all(12),
      itemCount: _controller.messages.length,
      itemBuilder: (context, index) {
        final message = _controller.messages[index];
        return _buildMessageBubble2(message);
      },
    );
  }


  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] == true;
    final isLoading = message['isLoading'] == true;
    final isSystem = message['isSystem'] == true;
    final hasActions = message['hasActions'] == true;

    if (isSystem) {
      return _buildSystemMessage(message);
    }

    if (hasActions) {
      return _buildActionMessage(message);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser && !isLoading)
            _buildAvatar(isUser: false),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Card(
                elevation: 1,
                color: isUser ? Colors.blue[50] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isLoading
                      ? _buildLoadingIndicator()
                      : Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          if (isUser && !isLoading)
            _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(Map<String, dynamic> message) {
    final text = message['text'] ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSystemIcon(text),
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble2(Map<String, dynamic> message) {
    final isUser = message['isUser'] == true;
    final isLoading = message['isLoading'] == true;
    final isSystem = message['isSystem'] == true;
    final hasActions = message['hasActions'] == true;

    if (isSystem) {
      return _buildSystemMessage(message);
    }

    if (hasActions) {
      return _buildActionMessage(message);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser && !isLoading)
            _buildAvatar(isUser: false),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Card(
                elevation: 1,
                color: isUser ? Colors.blue[50] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isLoading
                      ? _buildLoadingIndicator()
                      : _parseMarkdownText( // ĐÂY LÀ PHẦN CẦN SỬA
                    message['text'] ?? '',
                    isUser: isUser,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          if (isUser && !isLoading)
            _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  // THÊM HÀM MỚI VÀO CLASS _ChatScreenState
  Widget _parseMarkdownText(String text, {required bool isUser}) {
    final regex = RegExp(r'\*\*(.*?)\*\*');

    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Text thường trước đoạn in đậm
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 14,
              color: isUser ? Colors.blue[900] : Colors.black87,
            ),
          ),
        );
      }

      // Text in đậm
      spans.add(
        TextSpan(
          text: match.group(1), // chỉ lấy nội dung, bỏ **
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isUser ? Colors.blue[900] : Colors.black87,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Phần text còn lại sau cùng
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.blue[900] : Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }


  IconData _getSystemIcon(String text) {
    if (text.contains('📍')) return Icons.location_on;
    if (text.contains('🔄')) return Icons.refresh;
    if (text.contains('✅')) return Icons.check_circle;
    if (text.contains('❌')) return Icons.error;
    return Icons.info;
  }

  Widget _buildActionMessage(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message content
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Card(
              elevation: 2,
              color: Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Đã thu thập đủ thông tin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message['text'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            margin: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _controller.confirmAndSendRequest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, size: 16),
                      SizedBox(width: 6),
                      Text('Gửi yêu cầu ngay'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _controller.cancelRequest()     ,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Tiếp tục chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[100] : Colors.purple[100],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: isUser ? Colors.blue[700] : Colors.purple[700],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Đang xử lý...',
          style: TextStyle(color: Colors.blue[700]),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _controller.textController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 3,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => _controller.isLoading.value
              ? Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.textController.text.trim().isNotEmpty) {
      _controller.sendMessage();
    }
  }

  void _showExitConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Thoát chat?'),
        content: const Text('Bạn có chắc muốn thoát? Thông tin đã thu thập sẽ được lưu lại.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}