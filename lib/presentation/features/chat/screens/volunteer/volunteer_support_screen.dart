import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/chatbot/MinhChatbotSuggestion.dart';
import 'package:cuutrobaolu/presentation/features/chat/controller/volunteer/volunteer_support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VolunteerSupportScreen extends StatefulWidget {
  const VolunteerSupportScreen({super.key});

  @override
  State<VolunteerSupportScreen> createState() => _VolunteerSupportScreenState();
}

class _VolunteerSupportScreenState extends State<VolunteerSupportScreen> {
  final VolunteerSupportController _controller = Get.put(VolunteerSupportController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

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
    _inputController.dispose();
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
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trợ lý Tình nguyện viên',
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
      actions: [
        Obx(() => _controller.isLoading.value
            ? Padding(
          padding: EdgeInsets.all(MinhSizes.sm),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
        )
            : const SizedBox()),
        IconButton(
          icon: Icon(
            _controller.currentPosition.value != null
                ? Icons.location_on
                : Icons.location_off,
            color: _controller.currentPosition.value != null
                ? Colors.green
                : Colors.orange,
          ),
          onPressed: _controller.refreshLocation,
          tooltip: _controller.currentAddress.value.isNotEmpty
              ? _controller.currentAddress.value
              : 'Cập nhật vị trí',
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Column(
      children: [
        // Suggestion chips
        Container(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gợi ý nhanh:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: MinhSizes.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _controller.suggestions
                      .map((s) => Padding(
                    padding: EdgeInsets.only(right: MinhSizes.sm),
                    child: MinhChatbotSuggestion(
                      text: s,
                      onTap: () {
                        _controller.sendMessage(s);
                        _inputController.clear();
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: false, // QUAN TRỌNG: false để tin nhắn đi từ trên xuống
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            itemCount: _controller.messages.length,
            itemBuilder: (context, index) {
              final message = _controller.messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
      ],
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
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser && !isLoading)
            _buildAvatar(isUser: false),

          SizedBox(width: 8),

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
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                    bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: isLoading
                      ? _buildLoadingIndicator()
                      : _parseMarkdownText(
                    message['text'] ?? '',
                    isUser: isUser,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 8),

          if (isUser && !isLoading)
            _buildAvatar(isUser: true),
        ],
      ),
    );
  }

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

  Widget _buildSystemMessage(Map<String, dynamic> message) {
    final text = message['text'] ?? '';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            SizedBox(width: 6),
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

  IconData _getSystemIcon(String text) {
    if (text.contains('📍')) return Icons.location_on;
    if (text.contains('🔄')) return Icons.refresh;
    if (text.contains('✅')) return Icons.check_circle;
    if (text.contains('❌')) return Icons.error;
    return Icons.info;
  }

  Widget _buildActionMessage(Map<String, dynamic> message) {
    final actionType = message['actionType'];
    final isSOS = actionType == 'accept_sos';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
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
              color: isSOS ? Colors.orange[50] : Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSOS ? Icons.warning_amber : Icons.home,
                          color: isSOS ? Colors.orange[700] : Colors.green[700],
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isSOS ? 'YÊU CẦU CỨU TRỢ' : 'ĐỊA ĐIỂM TRÚ ẨN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSOS ? Colors.orange[700] : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      message['text'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            margin: EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isSOS) {
                      _controller.acceptSOSTask();
                    } else {
                      _controller.confirmShelter();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSOS ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 16),
                      SizedBox(width: 6),
                      Text(isSOS ? 'Nhận nhiệm vụ' : 'Xác nhận'),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: _controller.skipAction,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Tiếp tục chat'),
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
        SizedBox(width: 12),
        Text(
          'Đang xử lý...',
          style: TextStyle(color: Colors.blue[700]),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
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
                controller: _inputController,
                decoration: InputDecoration(
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
          SizedBox(width: 8),
          Obx(() => _controller.isLoading.value
              ? Container(
            width: 48,
            height: 48,
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_inputController.text.trim().isNotEmpty) {
      _controller.sendMessage(_inputController.text.trim());
      _inputController.clear();
    }
  }
}