import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dịch vụ AI chuyên biệt hỗ trợ giải thích kết quả xét nghiệm cận lâm sàng và đơn thuốc
class MedicalAiService {
  static final String _defaultApiKey =
      utf8.decode(base64.decode('QVEuQWI4Uk42Snp0RDdlZDlSRmdEWTNsT2JUQnVpLWcxZUpaUWVtR3FEczRhZmFQTDRjeEE='));
  static const String _prefKey = 'custom_gemini_api_key';

  static const List<String> _modelCandidates = [
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-3.8-flash',
  ];

  static final _systemInstruction = Content.system(
    'Bạn là Bác sĩ - Dược sĩ tư vấn y khoa cao cấp của phòng khám HUIT Care. '
    'Phong cách giao tiếp: Ân cần, đồng cảm, chuyên môn cao nhưng diễn giải bằng ngôn ngữ bình dân, dễ hiểu cho bệnh nhân và gia đình. '
    'Quy tắc bắt buộc: '
    '1. Trình bày rõ ràng theo từng phần bằng định dạng Markdown (gạch đầu dòng, in đậm từ khóa quan trọng). '
    '2. Phân tích xem chỉ số hoặc loại thuốc có ý nghĩa gì, bình thường hay bất thường. '
    '3. Đưa ra hướng dẫn thực tế về chế độ ăn uống, sinh hoạt, kiêng cữ cụ thể. '
    '4. LUÔN LUÔN kết thúc bằng câu nhắc nhở tôn trọng chỉ định của bác sĩ điều trị.',
  );

  /// Lấy API Key hiện hành (từ SharedPreferences hoặc fallback mặc định)
  static Future<String> _getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_prefKey);
      if (key != null && key.trim().isNotEmpty) {
        return key.trim();
      }
    } catch (_) {}
    return _defaultApiKey;
  }

  /// Giải thích kết quả xét nghiệm cận lâm sàng (Stream real-time)
  static Stream<String> streamExplainLabTest({
    required String testName,
    required String result,
    required String department,
    required String doctor,
    required String date,
  }) async* {
    final apiKey = await _getApiKey();

    final prompt = StringBuffer();
    prompt.writeln('Bệnh nhân vừa nhận được kết quả cận lâm sàng như sau:');
    prompt.writeln('- Dịch vụ xét nghiệm: $testName');
    prompt.writeln('- Chuyên khoa: $department');
    prompt.writeln('- Bác sĩ chỉ định: $doctor');
    prompt.writeln('- Ngày thực hiện: $date');
    prompt.writeln('- Kết quả chi tiết ghi trong hồ sơ: "$result"');
    prompt.writeln();
    prompt.writeln('Yêu cầu bạn giải thích cho bệnh nhân:');
    prompt.writeln('1. **Ý nghĩa kết quả**: Diễn giải kết quả này nghĩa là gì theo ngôn ngữ dễ hiểu.');
    prompt.writeln('2. **Đánh giá sơ bộ**: Bệnh nhân nên lưu tâm những điều gì từ chỉ số/kết luận trên?');
    prompt.writeln('3. **Lời khuyên dinh dưỡng & sinh hoạt**: Bệnh nhân nên ăn gì, kiêng gì, tập luyện ra sao?');
    prompt.writeln('4. **Lời dặn theo dõi**: Khi nào cần tái khám ngay?');

    yield* _streamGenerate(prompt.toString(), apiKey);
  }

  /// Giải thích đơn thuốc và hướng dẫn uống an toàn (Stream real-time)
  static Stream<String> streamExplainPrescription({
    required String diagnosis,
    required List<Map<String, String>> medications,
    String? doctorNote,
  }) async* {
    final apiKey = await _getApiKey();

    final prompt = StringBuffer();
    prompt.writeln('Bệnh nhân vừa khám xong với chẩn đoán: "$diagnosis".');
    if (doctorNote != null && doctorNote.isNotEmpty) {
      prompt.writeln('Lời dặn của Bác sĩ điều trị: "$doctorNote"');
    }
    prompt.writeln('Bác sĩ đã kê đơn gồm ${medications.length} loại thuốc:');
    for (int i = 0; i < medications.length; i++) {
      final med = medications[i];
      prompt.writeln(
        '${i + 1}. ${med['name']} - Số lượng: ${med['quantity']} - Cách dùng: ${med['dosage']}',
      );
    }
    prompt.writeln();
    prompt.writeln('Yêu cầu bạn giải thích cho bệnh nhân:');
    prompt.writeln('1. **Công dụng của từng thuốc**: Mỗi loại thuốc trên có tác dụng gì đối với bệnh lý $diagnosis?');
    prompt.writeln('2. **Lưu ý quan trọng khi uống**: Nên uống trước hay sau bữa ăn, cách nhau bao lâu? Tương tác thuốc cần tránh?');
    prompt.writeln('3. **Chế độ kiêng cữ**: Trong thời gian dùng đơn thuốc này cần kiêng ăn uống gì (ví dụ: rượu bia, chất kích thích...)?');
    prompt.writeln('4. **Tác dụng phụ thường gặp**: Nếu có cảm giác gì thì không cần quá lo lắng, và khi nào cần báo ngay bác sĩ?');

    yield* _streamGenerate(prompt.toString(), apiKey);
  }

  /// Gọi Gemini API với cơ chế dự phòng model tự động
  static Stream<String> _streamGenerate(String prompt, String apiKey) async* {
    final generationConfig = GenerationConfig(
      maxOutputTokens: 1000,
      temperature: 0.4,
      topP: 0.85,
    );

    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          systemInstruction: _systemInstruction,
          generationConfig: generationConfig,
        );

        final responseStream = model.generateContentStream([Content.text(prompt)]);

        await for (final chunk in responseStream) {
          final text = chunk.text;
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        }
        return; // Đã stream thành công, kết thúc
      } catch (e) {
        // Nếu model này bận/lỗi, tự động chuyển sang candidate kế tiếp
        continue;
      }
    }

    yield '\n⚠️ Rất tiếc, máy chủ AI y tế hiện đang bận xử lý hoặc không có phản hồi. Vui lòng thử lại sau ít phút!';
  }
}
