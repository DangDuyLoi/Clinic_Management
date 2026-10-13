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

  /// Đối tượng GenerativeModel của thư viện google_generative_ai
  late final GenerativeModel _generativeModel;

  // ===========================================================================
  // 3. VÒNG ĐỜI CONTROLLER & KHỞI TẠO MODEL
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    _initGenerativeModel();
    _sendInitialGreeting();
  }

  /// Khởi tạo model Gemini 1.5 Flash với System Instruction y tế chuyên biệt
  void _initGenerativeModel() {
    _generativeModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey:
          'YOUR_API_KEY', // Giữ nguyên chuỗi này để người dùng tự điền API Key
      systemInstruction: Content.system(
        'Bạn là trợ lý y tế thông minh của phòng khám đa khoa HUIT Care. '
        'Nhiệm vụ của bạn: 1. Hỏi han triệu chứng ngắn gọn. 2. Phân tích sơ bộ. 3. Hướng dẫn bệnh nhân đặt lịch đúng chuyên khoa. '
        'CHÚ Ý QUAN TRỌNG: Phòng khám chỉ có các khoa: Nội, Ngoại, Sản, Mắt, Tai Mũi Họng, Răng Hàm Mặt. '
        'TUYỆT ĐỐI KHÔNG CÓ KHOA NHI. Tuyệt đối không tự kê đơn hay chẩn đoán khẳng định bệnh.',
      ),
    );
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
  // 4. HÀM XỬ LÝ GỬI & NHẬN TIN NHẮN
  // ===========================================================================

  /// Gửi tin nhắn của người dùng và gọi Gemini API để nhận phản hồi
  Future<void> sendMessage(ChatMessage m) async {
    // Bước 1: Thêm tin nhắn của người dùng vào mảng messages (vị trí đầu mảng vì DashChat hiển thị ngược)
    messages.insert(0, m);

    // Bước 2: Bật hiệu ứng đang gõ tin nhắn (isTyping = true)
    isTyping.value = true;

    try {
      // Bước 3: Lọc lấy lịch sử messages hiện tại (loại bỏ tin nhắn 'm' vừa gửi),
      // sắp xếp từ cũ nhất đến mới nhất, rồi map sang cấu trúc Content.text() và Content.model()
      final List<ChatMessage> previousMessages = messages.reversed
          .where((msg) => msg != m)
          .toList();

      // Đảm bảo lịch sử gửi lên Gemini bắt đầu bằng lượt hỏi của người dùng (role 'user')
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

      // Khởi tạo phiên chat với context lịch sử cuộc trò chuyện
      final chatSession = _generativeModel.startChat(history: history);

      // Bước 4: Gọi chatSession.sendMessage() để gửi tin nhắn hiện tại
      final response = await chatSession.sendMessage(Content.text(m.text));

      final replyText =
          response.text?.trim() ??
          'Xin lỗi, hiện tại tôi chưa thể phân tích thông tin này. Bạn vui lòng thử lại nhé!';

      // Tạo một ChatMessage mới của geminiUser và add vào đầu mảng messages
      final geminiMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: replyText,
      );
      messages.insert(0, geminiMessage);
    } catch (e) {
      // Xử lý lỗi (lỗi mạng, API Key chưa hợp lệ,...)
      final errorMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text:
            'Đã có lỗi xảy ra khi kết nối tới Trợ lý AI. '
            'Vui lòng kiểm tra lại cấu hình API Key hoặc kết nối mạng của bạn.\n(Lỗi: $e)',
      );
      messages.insert(0, errorMessage);
    } finally {
      // Bước 5: Luôn tắt hiệu ứng typing trong khối finally
      isTyping.value = false;
    }
  }
}
