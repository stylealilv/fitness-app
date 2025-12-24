import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late GenerativeModel _model;
  bool _isInitialized = false;

  /// Khởi tạo Gemini với API key
  /// Bạn cần lấy API key từ: https://makersuite.google.com/app/apikey
  void initialize(String apiKey) {
    if (_isInitialized) return;

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    _isInitialized = true;
  }

  /// Gửi tin nhắn và nhận phản hồi từ Gemini
  Future<String> sendMessage(String message, {List<Content>? history}) async {
    if (!_isInitialized) {
      throw Exception(
          'GeminiService chưa được khởi tạo. Hãy gọi initialize() trước.');
    }

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Không nhận được phản hồi từ Gemini.';
    } catch (e) {
      return 'Lỗi khi gửi tin nhắn: ${e.toString()}';
    }
  }

  /// Gửi tin nhắn với lịch sử chat (để duy trì ngữ cảnh)
  Future<String> sendMessageWithHistory(
    String message,
    List<Content> history,
  ) async {
    if (!_isInitialized) {
      throw Exception(
          'GeminiService chưa được khởi tạo. Hãy gọi initialize() trước.');
    }

    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));

      return response.text ?? 'Không nhận được phản hồi từ Gemini.';
    } catch (e) {
      return 'Lỗi khi gửi tin nhắn: ${e.toString()}';
    }
  }

  /// Kiểm tra xem service đã được khởi tạo chưa
  bool get isInitialized => _isInitialized;
}
