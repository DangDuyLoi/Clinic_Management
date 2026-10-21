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

  /// API Key của Google Gemini API (lấy từ https://aistudio.google.com/app/apikey)
  /// Lưu ý: Cần API key hợp lệ bắt đầu bằng "AIzaSy..."
  static const String _apiKey =
      'AQ.Ab8RN6JXlDwB07JkbaLVgGsYzmw5riQ-_xiSZ7XgKI1_5yLW4Q';

  /// Danh sách các model chính thức của Google Gemini có tốc độ cao nhất (Flash)
  static const List<String> _modelCandidates = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash-8b',
  ];

  /// Giới hạn lịch sử hội thoại gửi lên (tối đa 6 tin nhắn gần nhất) để tối ưu tốc độ và payload
  static const int _maxHistoryMessages = 6;

  /// System Instruction y tế chuyên biệt, yêu cầu trả lời ngắn gọn súc tích để phản hồi nhanh nhất
  static final _systemInstruction = Content.system(
    'Bạn là trợ lý y tế thông minh của phòng khám đa khoa HUIT Care. '
    'Nhiệm vụ của bạn: '
    '1. Hỏi han triệu chứng ngắn gọn, ân cần. '
    '2. Phân tích sơ bộ nguyên nhân khả dĩ. '
    '3. Hướng dẫn bệnh nhân đặt lịch đúng chuyên khoa. '
    'CHÚ Ý QUAN TRỌNG: '
    '- Phòng khám chỉ có các khoa: Khoa Nội, Khoa Ngoại, Khoa Sản, Khoa Mắt, Khoa Tai Mũi Họng, Khoa Răng Hàm Mặt. '
    '- TUYỆT ĐỐI KHÔNG CÓ KHOA NHI. '
    '- Tuyệt đối không tự kê đơn thuốc điều trị hay chẩn đoán khẳng định bệnh. '
    '- YÊU CẦU ĐỘ DÀI: Trả lời ngắn gọn, súc tích (dưới 120 từ), đi thẳng vào vấn đề để phản hồi nhanh nhất cho người bệnh.',
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
  // 4. HÀM XỬ LÝ GỬI & NHẬN TIN NHẮN TỐC ĐỘ CAO (STREAMING + FALLBACK)
  // ===========================================================================

  /// Gửi tin nhắn của người dùng và gọi Gemini API với cơ chế STREAMING giúp phản hồi tức thì
  Future<void> sendMessage(ChatMessage m) async {
    // Bước 1: Thêm tin nhắn của người dùng vào danh sách
    messages.insert(0, m);

    // Bước 2: Bật hiệu ứng đang gõ tin nhắn (typing indicator)
    isTyping.value = true;

    // Bước 3: Chuẩn bị lịch sử trò chuyện (tối ưu: chỉ lấy các tin gần nhất)
    final List<ChatMessage> previousMessages = messages.reversed
        .where((msg) => msg != m)
        .toList();

    final int firstUserIndex = previousMessages.indexWhere(
      (msg) => msg.user.id == currentUser.id,
    );

    final List<Content> fullHistory = [];
    if (firstUserIndex != -1) {
      for (int i = firstUserIndex; i < previousMessages.length; i++) {
        final msg = previousMessages[i];
        if (msg.text.trim().isEmpty) continue;

        if (msg.user.id == currentUser.id) {
          fullHistory.add(Content.text(msg.text));
        } else {
          fullHistory.add(Content.model([TextPart(msg.text)]));
        }
      }
    }

    // Cắt bớt history nếu quá dài để tăng tốc độ phản hồi
    final List<Content> optimizedHistory = fullHistory.length > _maxHistoryMessages
        ? fullHistory.sublist(fullHistory.length - _maxHistoryMessages)
        : fullHistory;

    // Đảm bảo history bắt đầu bằng vai trò 'user' (yêu cầu bắt buộc của Gemini API)
    while (optimizedHistory.isNotEmpty && optimizedHistory.first.role != 'user') {
      optimizedHistory.removeAt(0);
    }

    bool streamStarted = false;
    final StringBuffer accumulatedText = StringBuffer();
    dynamic lastError;

    // Cấu hình sinh chữ tối ưu tốc độ: maxOutputTokens nhỏ + temperature vừa phải
    final generationConfig = GenerationConfig(
      maxOutputTokens: 400,
      temperature: 0.5,
      topP: 0.8,
    );

    // Thử lần lượt các model Flash tốc độ cao
    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          systemInstruction: _systemInstruction,
          generationConfig: generationConfig,
        );

        final chatSession = model.startChat(history: optimizedHistory);
        final responseStream =
            chatSession.sendMessageStream(Content.text(m.text));

        await for (final chunk in responseStream) {
          final chunkText = chunk.text;
          if (chunkText != null && chunkText.isNotEmpty) {
            accumulatedText.write(chunkText);

            if (!streamStarted) {
              streamStarted = true;
              isTyping.value = false; // Tắt typing ngay khi chunk đầu tiên xuất hiện (~0.5s)
              final initialBotMsg = ChatMessage(
                user: geminiUser,
                createdAt: DateTime.now(),
                text: accumulatedText.toString(),
              );
              messages.insert(0, initialBotMsg);
            } else {
              // Cập nhật text realtime giúp hiệu ứng gõ chữ mượt mà
              final updatedBotMsg = ChatMessage(
                user: geminiUser,
                createdAt: messages[0].createdAt,
                text: accumulatedText.toString(),
              );
              messages[0] = updatedBotMsg;
              messages.refresh();
            }
          }
        }

        // Nếu đã stream thành công câu trả lời
        if (streamStarted && accumulatedText.isNotEmpty) {
          break;
        }
      } catch (e) {
        lastError = e;
        // Nếu đã lỡ stream một phần chữ ra màn hình mà gặp ngắt mạng thì dừng, không fallback
        if (streamStarted) {
          break;
        }
      }
    }

    // Nếu không model nào thành công và chưa stream được chữ nào
    if (!streamStarted) {
      isTyping.value = false;
      String errorNotice =
          'Hiện tại máy chủ Trợ lý AI đang bận hoặc cấu hình API Key chưa chính xác. Vui lòng thử lại sau.';
      if (lastError != null) {
        final errStr = lastError.toString();
        if (errStr.contains('API_KEY_INVALID') ||
            errStr.contains('API key not valid') ||
            errStr.contains('UNAUTHENTICATED') ||
            errStr.contains('ACCESS_TOKEN_TYPE_UNSUPPORTED')) {
          errorNotice =
              'Lỗi xác thực API Key: Khóa API hiện tại không hợp lệ. Vui lòng điền API Key Google Gemini chính xác từ Google AI Studio (bắt đầu bằng "AIzaSy...").';
        } else {
          errorNotice += '\n(Chi tiết: $lastError)';
        }
      }

      final errorMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: errorNotice,
      );
      messages.insert(0, errorMessage);
    } else {
      isTyping.value = false;
    }
  }
}
