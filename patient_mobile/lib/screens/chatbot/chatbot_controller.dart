import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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

  /// Nhập liệu giọng nói (Voice-to-Text)
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool isSpeechAvailable = false.obs;
  final RxString voiceStatusText = ''.obs;
  final TextEditingController inputController = TextEditingController();

  /// API Key mặc định của Google Gemini API
  static final String _defaultApiKey =
      utf8.decode(base64.decode('QVEuQWI4Uk42Snp0RDdlZDlSRmdEWTNsT2JUQnVpLWcxZUpaUWVtR3FEczRhZmFQTDRjeEE='));

  /// Khóa API hiện hành (cho phép ghi đè linh hoạt qua Settings/Dialog)
  final RxString currentApiKey = _defaultApiKey.obs;

  static const String _prefKey = 'custom_gemini_api_key';

  /// Danh sách các model chính thức của Google Gemini có tốc độ cao nhất (Flash)
  static const List<String> _modelCandidates = [
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-3.8-flash',
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
    _loadCustomApiKey();
    _initSpeech();
    _sendInitialGreeting();
    _checkInitialArgument();
  }

  void _checkInitialArgument() {
    final args = Get.arguments;
    if (args is Map && args['initialPrompt'] != null) {
      final prompt = (args['initialPrompt'] as String).trim();
      if (prompt.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 350), () {
          sendMessage(ChatMessage(
            user: currentUser,
            createdAt: DateTime.now(),
            text: prompt,
          ));
        });
      }
    }
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speechToText.initialize(
        debugLogging: true,
        onStatus: (status) {
          debugPrint('SpeechToText Status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
            voiceStatusText.value = '';
          }
        },
        onError: (errorNotification) {
          debugPrint('SpeechToText Error: ${errorNotification.errorMsg} (permanent: ${errorNotification.permanent})');
          isListening.value = false;
          voiceStatusText.value = '';
        },
      );
      debugPrint('SpeechToText initialized. Available: $available');
      isSpeechAvailable.value = available;
    } catch (e, stack) {
      debugPrint('SpeechToText init error: $e\n$stack');
      isSpeechAvailable.value = false;
    }
  }

  /// Bật/Tắt chế độ thu âm nhận diện giọng nói
  Future<void> toggleVoiceRecording() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      voiceStatusText.value = '';
      return;
    }

    // 1. Kiểm tra và yêu cầu quyền Micro (Microphone Permission) trực tiếp từ hệ điều hành Android
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    if (micStatus.isPermanentlyDenied) {
      Get.defaultDialog(
        title: "Quyền truy cập Micro",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        middleText: "Ứng dụng cần quyền Micro để nhận diện giọng nói triệu chứng của bạn.\n\nVui lòng mở Cài đặt ứng dụng để bật quyền Micro.",
        textConfirm: "Mở Cài đặt",
        textCancel: "Đóng",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0056D2),
        onConfirm: () {
          Get.back();
          openAppSettings();
        },
      );
      return;
    }

    if (!micStatus.isGranted) {
      Get.snackbar(
        'Quyền Micro',
        'Vui lòng cấp quyền Micro để trò chuyện bằng giọng nói với Trợ lý AI.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Khởi tạo Speech-To-Text sau khi quyền Micro đã sẵn sàng
    if (!isSpeechAvailable.value) {
      await _initSpeech();
    }

    if (!isSpeechAvailable.value) {
      Get.defaultDialog(
        title: "Dịch vụ giọng nói",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        middleText: "Thiết bị chưa bật hoặc chưa cài đặt Dịch vụ giọng nói Google (Google Voice Typing) làm bàn phím nhập giọng nói mặc định.\n\nBạn hãy vào Cài đặt bàn phím & giọng nói để bật Dịch vụ Google.",
        textConfirm: "Mở Cài đặt",
        textCancel: "Đóng",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0056D2),
        onConfirm: () {
          Get.back();
          openAppSettings();
        },
      );
      return;
    }

    isListening.value = true;
    voiceStatusText.value = 'Đang nghe... Bạn hãy nói triệu chứng của mình.';

    try {
      String targetLocale = 'vi_VN';
      try {
        final locales = await _speechToText.locales();
        final hasVi = locales.any((l) => l.localeId.toLowerCase().startsWith('vi'));
        if (!hasVi && locales.isNotEmpty) {
          targetLocale = locales.first.localeId;
        }
      } catch (_) {}

      await _speechToText.listen(
        localeId: targetLocale,
        onResult: (result) {
          inputController.text = result.recognizedWords;
          if (result.finalResult) {
            isListening.value = false;
            voiceStatusText.value = '';
          }
        },
      );
    } catch (e) {
      debugPrint('SpeechToText listen error: $e');
      isListening.value = false;
      voiceStatusText.value = '';
    }
  }

  @override
  void onClose() {
    inputController.dispose();
    _speechToText.stop();
    super.onClose();
  }

  Future<void> _loadCustomApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefKey);
      if (savedKey != null && savedKey.trim().isNotEmpty) {
        currentApiKey.value = savedKey.trim();
      }
    } catch (_) {}
  }

  /// Cập nhật API Key mới và lưu vào máy
  Future<void> updateApiKey(String newKey) async {
    final trimmed = newKey.trim();
    if (trimmed.isEmpty) return;
    currentApiKey.value = trimmed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, trimmed);
    } catch (_) {}
  }

  /// Khôi phục API Key về mặc định
  Future<void> resetApiKey() async {
    currentApiKey.value = _defaultApiKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
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

    final activeKey = currentApiKey.value.trim().isNotEmpty
        ? currentApiKey.value.trim()
        : _defaultApiKey;

    // Thử lần lượt các model Flash tốc độ cao
    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: activeKey,
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
        if (errStr.contains('API_KEY_SERVICE_BLOCKED') ||
            errStr.contains('ACCESS_TOKEN_TYPE_UNSUPPORTED')) {
          errorNotice =
              '⚠️ Lỗi phân quyền API Key:\n'
              'Khóa API hiện tại đúng nhưng dịch vụ "Generative Language API" chưa được cấp quyền hoặc đang bị chặn trên Google Cloud Project.\n\n'
              '👉 Hướng dẫn khắc phục:\n'
              '1. Bấm biểu tượng ⚙️ ở góc trên bên phải màn hình này để cập nhật API Key mới.\n'
              '2. Hoặc truy cập Google AI Studio (https://aistudio.google.com/app/apikey), tạo 1 API Key mới trong project cá nhân và dán vào app.';
        } else if (errStr.contains('API_KEY_INVALID') ||
            errStr.contains('API key not valid') ||
            errStr.contains('UNAUTHENTICATED')) {
          errorNotice =
              '⚠️ Lỗi xác thực API Key: Khóa API hiện tại không hợp lệ. Vui lòng bấm biểu tượng ⚙️ ở góc trên bên phải để cập nhật API Key Google Gemini chính xác.';
        } else if (errStr.contains('RESOURCE_EXHAUSTED') || errStr.contains('quota')) {
          errorNotice =
              '⚠️ Khóa API đã đạt giới hạn hạn mức (Rate limit/Quota). Vui lòng thử lại sau ít phút hoặc đổi sang API Key khác qua nút ⚙️.';
        } else {
          errorNotice += '\n(Chi tiết kỹ thuật: $lastError)';
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
