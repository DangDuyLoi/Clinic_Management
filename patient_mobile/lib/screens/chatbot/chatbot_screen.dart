import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../../core/app_colors.dart';
import 'chatbot_controller.dart';

/// Màn hình giao diện Trợ lý Y tế AI (AI Healthcare Chatbot)
/// Sử dụng GetX và thư viện DashChat2 để hiển thị khung chat chuyên nghiệp
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo ChatbotController thông qua Get.put
    final ChatbotController controller = Get.put(ChatbotController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý y tế AI'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Obx(
        () => DashChat(
          // Người dùng hiện tại (bệnh nhân)
          currentUser: controller.currentUser,

          // Danh sách tin nhắn hiển thị (cần cast từ RxList sang List bình thường)
          messages: controller.messages.toList(),

          // Hàm callback khi người dùng gửi tin nhắn
          onSend: controller.sendMessage,

          // Danh sách người dùng đang soạn tin (hiển thị hiệu ứng ba chấm typing)
          typingUsers: controller.isTyping.value
              ? [controller.geminiUser]
              : <ChatUser>[],

          // Tùy chỉnh giao diện bong bóng tin nhắn (MessageOptions)
          messageOptions: MessageOptions(
            // Màu nền tin nhắn của currentUser (màu xanh chủ đạo của ứng dụng)
            currentUserContainerColor: AppColors.primary,
            currentUserTextColor: Colors.white,

            // Màu nền tin nhắn của geminiUser (màu xám nhạt)
            containerColor: Colors.grey.shade200,
            textColor: Colors.black87,

            // Hiển thị thời gian gửi tin nhắn
            showTime: true,
            timeTextColor: Colors.black54,

            // Tự động render markdown **in đậm** thành chữ in đậm thực sự
            messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
              final isUser = message.user.id == controller.currentUser.id;
              final baseStyle = TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.45,
              );
              return _buildFormattedMarkdownText(message.text, baseStyle);
            },

            // Yêu cầu 3: Nút điều hướng thông minh nằm ngay dưới bong bóng chat
            bottom: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
              return _buildSmartBookingButton(message, controller.geminiUser);
            },
          ),

          // Tùy chỉnh ô nhập văn bản và nút gửi
          inputOptions: const InputOptions(
            inputDecoration: InputDecoration(
              hintText: 'Nhập triệu chứng hoặc câu hỏi sức khỏe...',
              hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // YÊU CẦU 3: NÚT ĐIỀU HƯỚNG THÔNG MINH (SMART BOOKING ACTION)
  // ===========================================================================

  /// Kiểm tra tin nhắn của AI và tạo nút "Đặt lịch [Tên Khoa] ngay" nếu có nhắc đến chuyên khoa
  Widget _buildSmartBookingButton(ChatMessage message, ChatUser geminiUser) {
    // 1. Chỉ hiển thị nút điều hướng cho các phản hồi đến từ trợ lý ảo AI
    if (message.user.id != geminiUser.id) {
      return const SizedBox.shrink();
    }

    final String text = message.text;

    // 2. Danh sách 6 chuyên khoa hợp lệ của phòng khám HUIT Care
    final List<String> availableDepartments = [
      'Khoa Tai Mũi Họng',
      'Khoa Răng Hàm Mặt',
      'Khoa Ngoại',
      'Khoa Nội',
      'Khoa Sản',
      'Khoa Mắt',
    ];

    // 3. Quét kiểm tra xem tin nhắn có chứa tên chuyên khoa nào hay không (không phân biệt hoa thường)
    final List<String> matchedDepartments = availableDepartments.where((dept) {
      return text.toLowerCase().contains(dept.toLowerCase());
    }).toList();

    // Nếu không chứa từ khóa chuyên khoa nào, không hiển thị gì cả
    if (matchedDepartments.isEmpty) {
      return const SizedBox.shrink();
    }

    // 4. Render danh sách nút bấm tương ứng với các chuyên khoa được trợ lý AI đề xuất
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 6.0,
        children: matchedDepartments.map((deptName) {
          return ElevatedButton.icon(
            onPressed: () {
              // Điều hướng sang màn hình đặt lịch với argument là Tên Khoa
              Get.toNamed('/booking', arguments: deptName);
            },
            icon: const Icon(Icons.calendar_month, size: 16),
            label: Text('Đặt lịch $deptName ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Phân tích cú pháp Markdown để hiển thị **in đậm** thực sự thay vì in dấu sao thô
  Widget _buildFormattedMarkdownText(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    final List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        // Bên trong cặp dấu ** -> Render in đậm (màu xanh thương hiệu nếu là AI)
        spans.add(
          TextSpan(
            text: part,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: baseStyle.color == Colors.white
                  ? Colors.white
                  : const Color(0xFF0056D2),
            ),
          ),
        );
      } else {
        // Văn bản bình thường
        spans.add(
          TextSpan(
            text: part,
            style: baseStyle,
          ),
        );
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: baseStyle,
    );
  }
}

