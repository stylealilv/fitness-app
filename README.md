# 🏋️‍♂️ Fitness Workout App - Giao diện Flutter UI
---

## 🌟 Giới thiệu

**Fitness Workout App** là một bộ giao diện người dùng (UI Kit) được thiết kế dành cho các ứng dụng sức khỏe và thể chất. Với mục tiêu mang lại trải nghiệm người dùng mượt mà và thân thiện, dự án này cung cấp một loạt các màn hình và thành phần được thiết kế sẵn, giúp các nhà phát triển đẩy nhanh quá trình xây dựng ứng dụng của mình.

## ✨ Các tính năng nổi bật

Dự án bao gồm các màn hình và chức năng giao diện sau:

*    onboarding: Giới thiệu các tính năng chính của ứng dụng cho người dùng mới.
*   **🔐 Xác thực người dùng:** Giao diện cho màn hình Đăng nhập và Đăng ký.
*   **📊 Bảng điều khiển (Dashboard):** Màn hình chính hiển thị tổng quan về hoạt động, mục tiêu và các chỉ số sức khỏe.
*   **💪 Kế hoạch luyện tập:** Xem và quản lý lịch trình các bài tập hàng ngày.
*   **🥗 Theo dõi dinh dưỡng:** Giao diện để theo dõi lượng calo, bữa ăn và lượng nước uống.
*   **😴 Theo dõi giấc ngủ:** Giúp người dùng ghi lại và phân tích chất lượng giấc ngủ.
*   **🤖 Trợ lý AI (Chatbot):** Tích hợp Gemini AI để trả lời các câu hỏi về fitness, dinh dưỡng và sức khỏe.
*   **👤 Hồ sơ người dùng:** Quản lý thông tin cá nhân, mục tiêu và cài đặt.
*   **📈 Biểu đồ & Thống kê:** Sử dụng biểu đồ để trực quan hóa tiến trình và dữ liệu sức khỏe.

## 🖼️ Screenshots


## 🛠️ Công nghệ và Thư viện

Dự án được xây dựng bằng các công nghệ và thư viện hàng đầu:

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Ngôn ngữ:** [Dart](https://dart.dev/)
*   **Trợ lý AI:** [Google Generative AI (Gemini)](https://pub.dev/packages/google_generative_ai)
*   **Lưu trữ đám mây:** [Cloud Firestore](https://pub.dev/packages/cloud_firestore)
*   **Biểu đồ:** [fl_chart](https://pub.dev/packages/fl_chart)
*   **UI Components:**
    *   [carousel_slider](https://pub.dev/packages/carousel_slider)
    *   [simple_circular_progress_bar](https://pub.dev/packages/simple_circular_progress_bar)
    *   [animated_toggle_switch](https://pub.dev/packages/animated_toggle_switch)
    *   [readmore](https://pub.dev/packages/readmore)
*   **Quản lý State:** setState (có thể dễ dàng mở rộng với các giải pháp khác như Provider, BLoC).

## 🚀 Bắt đầu

Để chạy dự án trên máy của bạn, hãy làm theo các bước dưới đây.

### 1. Yêu cầu cài đặt

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (phiên bản 3.x)
*   [Android Studio](https://developer.android.com/studio) hoặc [VS Code](https://code.visualstudio.com/) với extension Flutter.
*   Một trình giả lập Android/iOS hoặc thiết bị thật.

### 2. Cài đặt

```bash
# 1. Clone repository về máy
git clone https://github.com/stylealilv/fitness-app

# 2. Di chuyển vào thư mục dự án
cd fitness-app

# 3. Cài đặt các gói phụ thuộc
flutter pub get
```

### 3. Cấu hình

Để tính năng **Trợ lý AI (Chatbot)** hoạt động, bạn cần cung cấp API Key của Google Gemini.

1.  Truy cập [Google AI Studio](https://makersuite.google.com/app/apikey) để tạo API Key.
2.  Mở tệp `lib/config/gemini_config.dart`.
3.  Thay thế chuỗi `YOUR_GEMINI_API_KEY` bằng API Key bạn vừa tạo:

    ```dart
    // lib/config/gemini_config.dart
    class GeminiConfig {
      static const String apiKey = 'YOUR_GEMINI_API_KEY'; // <--- THAY THẾ TẠI ĐÂY
      // ...
    }
    ```

### 4. Chạy ứng dụng

```bash
# Chạy ứng dụng trên thiết bị đã chọn
flutter run
```

## 📁 Cấu trúc mã nguồn (Folder Structure)

```text
lib/
├── models/      # Định nghĩa cấu trúc dữ liệu cho User, Exercise, Stats.
├── screens/     # Chứa mã nguồn của các màn hình chính (Home, Detail, Profile).
├── widgets/     # Các thành phần giao diện dùng chung (Custom Buttons, Cards, Bars).
├── utils/       # Định nghĩa màu sắc (colors.dart), hằng số và cấu hình theme.
└── main.dart    # Điểm khởi chạy ứng dụng.

Dự án được tổ chức theo cấu trúc hướng tính năng để dễ dàng quản lý và mở rộng.