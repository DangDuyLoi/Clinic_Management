import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/app_colors.dart';
import '../../../../services/medical_ai_service.dart';

/// BottomSheet hiển thị lời giải thích y khoa từ Trợ lý AI
class MedicalAiExplainerSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final Stream<String> explanationStream;
  final String fullPromptForChatbot;

  const MedicalAiExplainerSheet({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.explanationStream,
    required this.fullPromptForChatbot,
  }) : super(key: key);

  /// Helper mở modal giải thích kết quả xét nghiệm
  static void showLabTestExplainer(
    BuildContext context, {
    required String testName,
    required String result,
    required String department,
    required String doctor,
    required String date,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MedicalAiExplainerSheet(
        title: 'Giải thích kết quả xét nghiệm',
        subtitle: testName,
        explanationStream: MedicalAiService.streamExplainLabTest(
          testName: testName,
          result: result,
          department: department,
          doctor: doctor,
          date: date,
        ),
        fullPromptForChatbot:
            'Tôi muốn hỏi thêm về kết quả xét nghiệm "$testName" (Khoa $department) với kết quả: "$result".',
      ),
    );
  }

  /// Helper mở modal giải thích đơn thuốc
  static void showPrescriptionExplainer(
    BuildContext context, {
    required String diagnosis,
    required List<Map<String, String>> medications,
    String? doctorNote,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MedicalAiExplainerSheet(
        title: 'Giải thích & Lưu ý dùng đơn thuốc',
        subtitle: 'Chẩn đoán: $diagnosis',
        explanationStream: MedicalAiService.streamExplainPrescription(
          diagnosis: diagnosis,
          medications: medications,
          doctorNote: doctorNote,
        ),
        fullPromptForChatbot:
            'Tôi muốn hỏi thêm về đơn thuốc điều trị bệnh "$diagnosis" gồm ${medications.length} loại thuốc.',
      ),
    );
  }

  @override
  State<MedicalAiExplainerSheet> createState() => _MedicalAiExplainerSheetState();
}

class _MedicalAiExplainerSheetState extends State<MedicalAiExplainerSheet> {
  final StringBuffer _accumulatedText = StringBuffer();
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _startListeningStream();
  }

  void _startListeningStream() {
    widget.explanationStream.listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _accumulatedText.write(chunk);
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _accumulatedText.toString();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle pill
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0056D2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF0056D2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Nội dung giải thích
          Expanded(
            child: text.isEmpty && _isGenerating
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2.5),
                        const SizedBox(height: 16),
                        Text(
                          'Bác sĩ AI đang phân tích dữ liệu y khoa...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormattedContent(text),
                        if (_isGenerating) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đang hoàn tất phân tích...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Disclaimer y tế
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lưu ý: Lời giải thích từ Trợ lý AI chỉ mang tính chất tham khảo kiến thức y khoa, không thay thế cho chẩn đoán hay chỉ định của Bác sĩ điều trị trực tiếp.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.amber.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                // Nút sao chép
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Sao chép'),
                  onPressed: text.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: text));
                          Get.snackbar(
                            'Đã sao chép',
                            'Đã lưu lời giải thích vào khay nhớ tạm',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                ),
                const SizedBox(width: 12),

                // Nút chuyển sang Chatbot
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Hỏi thêm trong Chatbot',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(
                        '/chatbot',
                        arguments: {'initialPrompt': widget.fullPromptForChatbot},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phân tích và hiển thị Markdown in đậm / gạch đầu dòng
  Widget _buildFormattedContent(String rawText) {
    final lines = rawText.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Tiêu đề hoặc danh mục chính (ví dụ: 1. **Ý nghĩa kết quả**:)
      if (trimmed.startsWith('#') ||
          trimmed.contains('**1.') ||
          trimmed.contains('**2.') ||
          trimmed.contains('**3.') ||
          trimmed.contains('**4.')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: _buildInlineMarkdown(
              trimmed.replaceAll('#', '').trim(),
              const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056D2),
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('-') || trimmed.startsWith('•')) {
        // Gạch đầu dòng
        final content = trimmed.substring(1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                Expanded(
                  child: _buildInlineMarkdown(
                    content,
                    const TextStyle(fontSize: 13.5, height: 1.45, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Đoạn văn thông thường
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildInlineMarkdown(
              trimmed,
              const TextStyle(fontSize: 13.5, height: 1.45, color: Colors.black87),
            ),
          ),
        );
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildInlineMarkdown(String text, TextStyle baseStyle) {
    final parts = text.split('**');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        spans.add(
          TextSpan(
            text: part,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: part, style: baseStyle));
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: baseStyle,
    );
  }
}
