import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Controller quản lý logic của Trợ lý Y tế AI (AI Healthcare Chatbot)
/// Sử dụng GetX để quản lý trạng thái (state management) và tích hợp Google Gemini AI
class ChatbotController extends GetxController {
  // ===========================================================================
  // 1. KHAI BÁO CÁC USER THAM GIA CHAT
  // ===========================================================================

  /// Đại diện cho bệnh nhân đang sử dụng ứng dụng
  final ChatUser currentUser = ChatUser(id: '1', firstName: 'Bệnh nhân');

  /// Đại diện cho trợ lý ảo AI của phòng khám HUIT Care
  final ChatUser geminiUser = ChatUser(
    id: '2',
    firstName: 'HUIT Care AI',
    profileImage:
        'https://cdn-icons-png.flaticon.com/512/387/387561.png', // Avatar AI Bác sĩ
  );

  // ===========================================================================
  // 2. STATE QUẢN LÝ DỮ LIỆU & GIAO DIỆN
  // ===========================================================================

  /// Danh sách các tin nhắn hiển thị trong màn hình chat (.obs để cập nhật UI tự động)
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Trạng thái đang xử lý / AI đang gõ phản hồi (.obs để cập nhật typing indicator)
  final RxBool isTyping = false.obs;

  static const String _apiKey =
      'AQ.Ab8RN6JXlDwB07JkbaLVgGsYzmw5riQ-_xiSZ7XgKI1_5yLW4Q';

  static const List<String> _modelCandidates = [
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-3.1-flash-lite',
  ];

  static final _systemInstruction = Content.system(
    'Bạn là trợ lý y tế thông minh của phòng khám đa khoa HUIT Care. '
    'Nhiệm vụ của bạn: 1. Hỏi han triệu chứng ngắn gọn, ân cần. 2. Phân tích sơ bộ nguyên nhân khả dĩ. 3. Hướng dẫn bệnh nhân đặt lịch đúng chuyên khoa. '
    'CHÚ Ý QUAN TRỌNG: Phòng khám chỉ có các khoa: Nội, Ngoại, Sản, Mắt, Tai Mũi Họng, Răng Hàm Mặt. '
    'TUYỆT ĐỐI KHÔNG CÓ KHOA NHI. Tuyệt đối không tự kê đơn thuốc điều trị hay chẩn đoán khẳng định bệnh.',
  );

  // ===========================================================================
  // 3. VÒNG ĐỜI CONTROLLER
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    _sendInitialGreeting();
  }

  /// Gửi tin nhắn chào mừng và hướng dẫn ban đầu từ phía Trợ lý AI
  void _sendInitialGreeting() {
    final welcomeMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text:
          'Xin chào! Tôi là Trợ lý Y tế AI của phòng khám HUIT Care.\n\n'
          'Tôi có thể hỗ trợ lắng nghe triệu chứng ban đầu và hướng dẫn bạn chọn chuyên khoa khám phù hợp. '
          'Hôm nay bạn đang cảm thấy không khỏe ở đâu hay có triệu chứng gì cần tư vấn?',
    );
    messages.insert(0, welcomeMessage);
  }

  // ===========================================================================
  // 4. HÀM XỬ LÝ GỬI & NHẬN TIN NHẮN VỚI TỰ ĐỘNG CHUYỂN MODEL KHI BỊ QUÁ TẢI (FALLBACK)
  // ===========================================================================

  /// Gửi tin nhắn của người dùng và gọi Gemini API để nhận phản hồi
  Future<void> sendMessage(ChatMessage m) async {
    // Bước 1: Thêm tin nhắn của người dùng vào mảng messages
    messages.insert(0, m);

    // Bước 2: Bật hiệu ứng đang gõ tin nhắn
    isTyping.value = true;

    // Chuẩn bị lịch sử trò chuyện
    final List<ChatMessage> previousMessages = messages.reversed
        .where((msg) => msg != m)
        .toList();

    final int firstUserIndex = previousMessages.indexWhere(
      (msg) => msg.user.id == currentUser.id,
    );

    final List<Content> history = [];
    if (firstUserIndex != -1) {
      for (int i = firstUserIndex; i < previousMessages.length; i++) {
        final msg = previousMessages[i];
        if (msg.text.trim().isEmpty) continue;

        if (msg.user.id == currentUser.id) {
          history.add(Content.text(msg.text));
        } else {
          history.add(Content.model([TextPart(msg.text)]));
        }
      }
    }

    String? replyText;
    dynamic lastError;

    // Thử lần lượt các model cho đến khi thành công
    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          systemInstruction: _systemInstruction,
        );

        final chatSession = model.startChat(history: history);
        final response = await chatSession.sendMessage(Content.text(m.text));

        if (response.text != null && response.text!.trim().isNotEmpty) {
          replyText = response.text!.trim();
          break; // Thành công, thoát vòng lặp fallback
        }
      } catch (e) {
        lastError = e;
        // Tiếp tục thử model dự phòng tiếp theo
      }
    }

    if (replyText != null) {
      final geminiMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: replyText,
      );
      messages.insert(0, geminiMessage);
    } else {
      final errorMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text:
            'Hiện tại máy chủ Trợ lý AI đang có lưu lượng truy cập cao. '
            'Vui lòng thử lại sau giây lát.\n(Chi tiết: $lastError)',
      );
      messages.insert(0, errorMessage);
    }

    isTyping.value = false;
  }
}
