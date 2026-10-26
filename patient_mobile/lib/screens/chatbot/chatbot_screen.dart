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
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Cài đặt API Key',
            onPressed: () => _showApiKeyDialog(context, controller),
          ),
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            // Thanh trạng thái nhận diện giọng nói thời gian thực
            if (controller.isListening.value)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.voiceStatusText.value.isNotEmpty
                            ? controller.voiceStatusText.value
                            : 'Đang lắng nghe... Hãy nói triệu chứng của bạn',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.toggleVoiceRecording,
                      child: const Text('Xong', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: DashChat(
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

                  // Nút điều hướng thông minh nằm ngay dưới bong bóng chat
                  bottom: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
                    return _buildSmartBookingButton(message, controller.geminiUser);
                  },
                ),

                // Tùy chỉnh ô nhập văn bản và nút Mic Voice-to-Text
                inputOptions: InputOptions(
                  textController: controller.inputController,
                  inputDecoration: const InputDecoration(
                    hintText: 'Nhập hoặc bấm Mic nói triệu chứng...',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  trailing: [
                    IconButton(
                      icon: Icon(
                        controller.isListening.value ? Icons.mic : Icons.mic_none,
                        color: controller.isListening.value ? Colors.red : AppColors.primary,
                        size: 24,
                      ),
                      tooltip: 'Nói triệu chứng (Voice-to-Text)',
                      onPressed: controller.toggleVoiceRecording,
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  // ===========================================================================
  // HỘP THOẠI CẤU HÌNH API KEY GOOGLE GEMINI
  // ===========================================================================
  void _showApiKeyDialog(BuildContext context, ChatbotController controller) {
    final textController = TextEditingController();
    final currentKey = controller.currentApiKey.value;
    final maskedKey = currentKey.length > 12
        ? '${currentKey.substring(0, 6)}...${currentKey.substring(currentKey.length - 6)}'
        : currentKey;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Cấu hình Gemini API Key', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nếu gặp lỗi xác thực hoặc hết hạn mức, bạn có thể nhập API Key Google Gemini cá nhân để tiếp tục trò chuyện.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Text('Khóa hiện tại: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(
                      child: Text(
                        maskedKey,
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Dán API Key mới vào đây',
                  hintText: 'AQ... hoặc AIzaSy...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '💡 Bạn có thể tạo key miễn phí tại: aistudio.google.com/app/apikey',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.resetApiKey();
              if (ctx.mounted) Navigator.pop(ctx);
              Get.snackbar(
                'Đã khôi phục',
                'API Key đã trở về khóa mặc định của hệ thống',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Mặc định', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newKey = textController.text.trim();
              if (newKey.isNotEmpty) {
                await controller.updateApiKey(newKey);
                if (ctx.mounted) Navigator.pop(ctx);
                Get.snackbar(
                  'Thành công',
                  'Đã cập nhật API Key mới cho trợ lý AI',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Lưu & Áp dụng'),
          ),
        ],
      ),
    );
  }
}

