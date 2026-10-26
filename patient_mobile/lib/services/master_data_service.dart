import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Dịch vụ tải và quản lý Master Data (Dân tộc, Nghề nghiệp, Mối quan hệ, Quốc gia)
/// Áp dụng cơ chế Cache-First (Stale-While-Revalidate) đảm bảo hoạt động Offline 100%
class MasterDataService {
  static const String _prefKey = 'master_data_cache_v1';

  // ===========================================================================
  // DỮ LIỆU DỰ PHÒNG CHUẨN (FALLBACK DEFAULTS KHI CHƯA CÓ MẠNG)
  // ===========================================================================
  static const List<String> defaultEthnicGroups = [
    'Kinh', 'Tày', 'Thái', 'Mường', 'H Mông', 'Dao', 'Khmer', 'Nùng', 'Hoa', 'Gia Rai',
    'Ê Đê', 'Ba Na', 'Xơ Đăng', 'Sán Chay', 'Cơ Ho', 'Chăm', 'Sán Dìu', 'Hrê', 'Ra Glai',
    'M Nông', 'Xtiêng', 'Bru - Vân Kiều', 'Thổ', 'Khơ Mú', 'Cơ Tu', 'Giáy', 'Giẻ Triêng',
    'Tà Ôi', 'Mạ', 'Co', 'Chơ Ro', 'Hà Nhì', 'Xinh Mun', 'Chu Ru', 'Lào', 'La Chí',
    'Kháng', 'Phù Lá', 'La Ha', 'La Hủ', 'Lự', 'Lô Lô', 'Chứt', 'Mảng', 'Pà Thẻn',
    'Cơ Lao', 'Cống', 'Bố Y', 'Si La', 'Pu Péo', 'Rơ Măm', 'Brâu', 'Ơ Đu'
  ];

  static const List<String> defaultRelationships = [
    'Bản thân',
    'Vợ / Chồng',
    'Bố / Mẹ',
    'Con cái',
    'Anh / Chị / Em ruột',
    'Ông / Bà',
    'Người bảo trợ / Người giám hộ',
    'Họ hàng / Người thân thích'
  ];

  static const List<String> defaultOccupations = [
    'Cán bộ / Công chức / Viên chức',
    'Công nhân / Người lao động',
    'Doanh nhân / Chủ doanh nghiệp / Quản lý',
    'Giáo viên / Giảng viên / Nghiên cứu sinh',
    'Học sinh / Sinh viên',
    'Hưu trí / Người cao tuổi',
    'Kế toán / Kiểm toán / Ngân hàng',
    'Kinh doanh / Buôn bán / Thương nhân',
    'Kỹ sư / Chuyên viên CNTT / Kỹ thuật',
    'Lao động tự do / Làm việc độc lập',
    'Lực lượng vũ trang (Công an, Quân đội)',
    'Luật sư / Chuyên viên pháp lý',
    'Nghệ sĩ / Diễn viên / Thiết kế / Báo chí',
    'Nông dân / Ngư dân / Lâm nghiệp',
    'Nội trợ',
    'Tài xế / Giao nhận / Logistics'
  ];

  static const List<String> defaultCountries = [
    'Việt Nam',
    'Hoa Kỳ (Mỹ)',
    'Nhật Bản',
    'Hàn Quốc',
    'Trung Quốc',
    'Úc (Australia)',
    'Anh (United Kingdom)',
    'Pháp (France)',
    'Đức (Germany)',
    'Canada',
    'Singapore',
    'Thái Lan',
    'Malaysia',
    'Lào',
    'Campuchia',
    'Đài Loan (Taiwan)',
    'Nga (Russia)'
  ];

  // In-memory active lists
  static List<String> ethnicGroups = List.from(defaultEthnicGroups);
  static List<String> relationships = List.from(defaultRelationships);
  static List<String> occupations = List.from(defaultOccupations);
  static List<String> countries = List.from(defaultCountries);

  /// Khởi tạo và đồng bộ Master Data:
  /// 1. Tải cache từ SharedPreferences ngay lập tức (0ms).
  /// 2. Gửi request ngầm lên Backend Laravel để cập nhật dữ liệu mới nhất.
  static Future<void> initialize() async {
    await _loadFromLocalCache();
    // Đồng bộ nền từ Backend API Laravel
    _fetchAndSyncFromBackend();
  }

  static Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_prefKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(cachedStr);
        _applyData(json);
      }
    } catch (_) {}
  }

  static Future<void> _fetchAndSyncFromBackend() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/patient-profiles/metadata');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonBody['success'] == true && jsonBody['data'] != null) {
          final data = jsonBody['data'] as Map<String, dynamic>;
          _applyData(data);

          // Ghi đè bộ nhớ đệm
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefKey, jsonEncode(data));
        }
      }
    } catch (_) {
      // Nếu offline, tiếp tục dùng cache hoặc fallback an toàn
    }
  }

  static void _applyData(Map<String, dynamic> data) {
    if (data['ethnic_groups'] is List) {
      ethnicGroups = List<String>.from(data['ethnic_groups']);
    }
    if (data['relationships'] is List) {
      relationships = List<String>.from(data['relationships']);
    }
    if (data['occupations'] is List) {
      occupations = List<String>.from(data['occupations']);
    }
    if (data['countries'] is List) {
      countries = List<String>.from(data['countries']);
    }
  }
}
