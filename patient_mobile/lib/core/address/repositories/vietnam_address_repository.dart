import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/master_data_service.dart';
import '../data/international_address_data.dart';
import '../models/administrative_unit.dart';
import 'address_repository.dart';

/// Repository địa giới hành chính kết nối API Quốc gia (provinces.open-api.vn)
/// Có bộ nhớ đệm (Cache) tốc độ cao và cơ chế dự phòng offline an toàn
class VietnamAddressRepository implements IAddressRepository {
  static const String _apiBase = 'https://provinces.open-api.vn/api';

  // Cache in-memory để chuyển trang mượt mà không cần load lại
  static List<AdministrativeUnit>? _cachedProvinces;
  static final Map<String, List<AdministrativeUnit>> _cachedDistrictsByProvince = {};
  static final Map<String, List<AdministrativeUnit>> _cachedWardsByDistrict = {};

  // Map lưu mã code (id số) của đơn vị hành chính phục vụ gọi API cấp con
  static final Map<String, String> _provinceNameToCode = {};
  static final Map<String, String> _districtNameToCode = {};

  @override
  Future<List<AdministrativeUnit>> getCountries() async {
    return MasterDataService.countries
        .map((c) => AdministrativeUnit(id: c, name: c))
        .toList();
  }

  @override
  Future<List<AdministrativeUnit>> getProvinces(String countryName) async {
    if (!countryName.contains('Việt Nam')) {
      return _getForeignProvinces(countryName);
    }

    if (_cachedProvinces != null && _cachedProvinces!.isNotEmpty) {
      return _cachedProvinces!;
    }

    try {
      final res = await http.get(Uri.parse('$_apiBase/?depth=1')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 || res.statusCode == 302) {
        final List<dynamic> list = jsonDecode(utf8.decode(res.bodyBytes));
        final result = list.map((item) {
          final name = item['name'] as String;
          final code = item['code'].toString();
          _provinceNameToCode[name] = code;
          return AdministrativeUnit(
            id: name,
            name: name,
            code: code,
            parentId: countryName,
          );
        }).toList();

        _cachedProvinces = result;
        return result;
      }
    } catch (_) {}

    return _fallbackProvinces;
  }

  @override
  Future<List<AdministrativeUnit>> getDistricts(
    String countryName,
    String provinceName,
  ) async {
    if (!countryName.contains('Việt Nam')) {
      return _getForeignDistricts(countryName, provinceName);
    }

    if (_cachedDistrictsByProvince.containsKey(provinceName)) {
      return _cachedDistrictsByProvince[provinceName]!;
    }

    final provinceCode = _provinceNameToCode[provinceName];
    if (provinceCode != null) {
      try {
        final res = await http
            .get(Uri.parse('$_apiBase/p/$provinceCode?depth=2'))
            .timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          final List<dynamic> districts = data['districts'] ?? [];

          final result = districts.map((item) {
            final name = item['name'] as String;
            final code = item['code'].toString();
            _districtNameToCode[name] = code;
            return AdministrativeUnit(
              id: name,
              name: name,
              code: code,
              parentId: provinceName,
            );
          }).toList();

          _cachedDistrictsByProvince[provinceName] = result;
          return result;
        }
      } catch (_) {}
    }

    return _fallbackDistricts(provinceName);
  }

  @override
  Future<List<AdministrativeUnit>> getWards(
    String countryName,
    String districtName,
  ) async {
    if (!countryName.contains('Việt Nam')) {
      return _getForeignWards(countryName, districtName);
    }

    if (_cachedWardsByDistrict.containsKey(districtName)) {
      return _cachedWardsByDistrict[districtName]!;
    }

    final districtCode = _districtNameToCode[districtName];
    if (districtCode != null) {
      try {
        final res = await http
            .get(Uri.parse('$_apiBase/d/$districtCode?depth=2'))
            .timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          final List<dynamic> wards = data['wards'] ?? [];

          final result = wards.map((item) {
            final name = item['name'] as String;
            final code = item['code'].toString();
            return AdministrativeUnit(
              id: name,
              name: name,
              code: code,
              parentId: districtName,
            );
          }).toList();

          _cachedWardsByDistrict[districtName] = result;
          return result;
        }
      } catch (_) {}
    }

    return _fallbackWards(districtName);
  }

  // ===========================================================================
  // DỮ LIỆU DỰ PHÒNG OFFLINE AN TOÀN KHI MẤT MẠNG HOÀN TOÀN
  // ===========================================================================
  static final List<AdministrativeUnit> _fallbackProvinces = [
    'Thành phố Hồ Chí Minh', 'Thành phố Hà Nội', 'Thành phố Đà Nẵng', 'Thành phố Hải Phòng',
    'Thành phố Cần Thơ', 'Tỉnh Bình Dương', 'Tỉnh Đồng Nai', 'Tỉnh Bà Rịa - Vũng Tàu',
    'Tỉnh Long An', 'Tỉnh Tiền Giang', 'Tỉnh An Giang', 'Tỉnh Khánh Hòa', 'Tỉnh Lâm Đồng',
    'Tỉnh Thừa Thiên Huế', 'Tỉnh Quảng Nam', 'Tỉnh Quảng Ninh', 'Tỉnh Thanh Hóa', 'Tỉnh Nghệ An'
  ].map((p) => AdministrativeUnit(id: p, name: p, parentId: 'Việt Nam')).toList();

  static List<AdministrativeUnit> _fallbackDistricts(String province) {
    if (province.contains('Hồ Chí Minh')) {
      return [
        'Quận 1', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 7', 'Quận 10', 'Quận Bình Thạnh',
        'Quận Tân Bình', 'Quận Gò Vấp', 'Thành phố Thủ Đức', 'Huyện Bình Chánh', 'Huyện Hóc Môn'
      ].map((d) => AdministrativeUnit(id: d, name: d, parentId: province)).toList();
    }
    if (province.contains('Hà Nội')) {
      return [
        'Quận Ba Đình', 'Quận Hoàn Kiếm', 'Quận Cầu Giấy', 'Quận Đống Đa', 'Quận Hai Bà Trưng',
        'Quận Thanh Xuân', 'Quận Nam Từ Liêm', 'Quận Bắc Từ Liêm', 'Quận Hoàng Mai', 'Huyện Gia Lâm'
      ].map((d) => AdministrativeUnit(id: d, name: d, parentId: province)).toList();
    }
    return [
      'Thành phố trung tâm', 'Quận 1', 'Thị xã trung tâm', 'Huyện 1', 'Huyện 2'
    ].map((d) => AdministrativeUnit(id: d, name: d, parentId: province)).toList();
  }

  static List<AdministrativeUnit> _fallbackWards(String district) {
    return [
      'Phường 1', 'Phường 2', 'Phường 3', 'Phường Bến Nghé', 'Phường Trung Tâm', 'Thị trấn Trung Tâm', 'Xã Tân Hiệp'
    ].map((w) => AdministrativeUnit(id: w, name: w, parentId: district)).toList();
  }

  static List<AdministrativeUnit> _getForeignProvinces(String country) {
    final list = InternationalAddressData.getProvinces(country);
    return list.map((p) => AdministrativeUnit(id: p, name: p, parentId: country)).toList();
  }

  static List<AdministrativeUnit> _getForeignDistricts(String country, String province) {
    final list = InternationalAddressData.getDistricts(country, province);
    return list.map((d) => AdministrativeUnit(id: d, name: d, parentId: province)).toList();
  }

  static List<AdministrativeUnit> _getForeignWards(String country, String district) {
    final list = InternationalAddressData.getWards(country, district);
    return list.map((w) => AdministrativeUnit(id: w, name: w, parentId: district)).toList();
  }
}
