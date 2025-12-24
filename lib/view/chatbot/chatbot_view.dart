import 'package:flutter/material.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/services/gemini_service.dart';
import 'package:fitness/config/gemini_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _loadChatHistory();
  }

  /// Khởi tạo Gemini với API key
  /// LƯU Ý: Bạn cần cấu hình API key trong file lib/config/gemini_config.dart
  /// Lấy API key tại: https://makersuite.google.com/app/apikey
  void _initializeGemini() {
    if (GeminiConfig.isConfigured) {
      _geminiService.initialize(GeminiConfig.apiKey);
      setState(() {
        _isInitialized = true;
      });
      _addSystemMessage(
          'Xin chào! Tôi là trợ lý AI của bạn. Tôi có thể giúp gì cho bạn về fitness, workout, dinh dưỡng và sức khỏe?');
    } else {
      _addSystemMessage(
          '⚠️ Vui lòng cấu hình Gemini API key trong file lib/config/gemini_config.dart\n\nHướng dẫn:\n1. Lấy API key từ: https://makersuite.google.com/app/apikey\n2. Mở file lib/config/gemini_config.dart\n3. Thay YOUR_GEMINI_API_KEY bằng API key thực tế');
    }
  }

  /// Load lịch sử chat từ Firebase
  void _loadChatHistory() async {
    try {
      // Kiểm tra Firebase đã được khởi tạo chưa
      if (Firebase.apps.isNotEmpty) {
        // Có thể load từ Firestore nếu cần lưu lịch sử
        // final snapshot = await FirebaseFirestore.instance
        //     .collection('chat_history')
        //     .orderBy('timestamp', descending: true)
        //     .limit(50)
        //     .get();
        // Load messages từ snapshot...
      }
    } catch (e) {
      // Ignore nếu chưa setup Firebase
      debugPrint('Firebase chưa được khởi tạo hoặc có lỗi: $e');
    }
  }

  /// Lưu tin nhắn vào Firebase (tùy chọn)
  void _saveMessageToFirebase(
      String message, String response, bool isUser) async {
    try {
      // Chỉ lưu nếu Firebase đã được khởi tạo
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('chat_history').add({
          'message': message,
          'response': response,
          'isUser': isUser,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Ignore nếu chưa setup Firebase hoặc không muốn lưu
      debugPrint('Không thể lưu vào Firebase: $e');
    }
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || !_isInitialized) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Thêm tin nhắn của user vào danh sách
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Tạo lịch sử chat từ các tin nhắn trước đó (trừ tin nhắn vừa thêm)
      List<Content> history = [];
      for (int i = 0; i < _messages.length - 1; i++) {
        var msg = _messages[i];
        if (msg.isUser) {
          history.add(Content.text(msg.text));
        } else {
          history.add(Content.model([TextPart(msg.text)]));
        }
      }

      // Gửi tin nhắn đến Gemini
      final response = await _geminiService.sendMessageWithHistory(
        userMessage,
        history,
      );

      // Lưu vào Firebase (tùy chọn)
      _saveMessageToFirebase(userMessage, response, true);
      _saveMessageToFirebase(response, response, false);

      // Thêm phản hồi từ AI
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin lỗi, đã xảy ra lỗi: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.smart_toy, color: TColor.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                Text(
                  'Trợ lý Fitness',
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.primaryG),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(Icons.smart_toy,
                              color: TColor.white, size: 40),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Xin chào! Tôi có thể giúp gì cho bạn?',
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 16,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hỏi tôi về workout, dinh dưỡng, sức khỏe...',
                          style: TextStyle(
                            color: TColor.gray.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TColor.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                            color: TColor.gray,
                            fontFamily: "Poppins",
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: TColor.black,
                          fontFamily: "Poppins",
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      TColor.white),
                                ),
                              ),
                            )
                          : Icon(Icons.send, color: TColor.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.smart_toy, color: TColor.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? TColor.primaryColor1 : TColor.lightGray,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? TColor.white : TColor.black,
                  fontSize: 15,
                  fontFamily: "Poppins",
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, color: TColor.primaryColor1, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.smart_toy, color: TColor.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang suy nghĩ...',
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
