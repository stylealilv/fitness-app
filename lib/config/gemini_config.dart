/// File cấu hình Gemini API Key
///
/// HƯỚNG DẪN:
/// 1. Lấy API key từ: https://makersuite.google.com/app/apikey
/// 2. Thay YOUR_GEMINI_API_KEY bằng API key thực tế của bạn
/// 3. KHÔNG commit file này lên Git nếu chứa API key thật
class GeminiConfig {
  /// API Key của Gemini Pro
  /// Thay đổi giá trị này bằng API key thực tế của bạn
  static const String apiKey = 'it's not good for this thing buddy xD';

  /// Kiểm tra API key đã được cấu hình chưa
  static bool get isConfigured =>
      apiKey != 'YOUR_GEMINI_API_KEY' && apiKey.isNotEmpty;
}
