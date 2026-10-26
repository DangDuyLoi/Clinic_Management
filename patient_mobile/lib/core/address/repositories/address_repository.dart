import '../models/administrative_unit.dart';

/// Contract trừu tượng cho nguồn dữ liệu địa giới hành chính (DIP trong SOLID)
abstract class IAddressRepository {
  /// Lấy danh sách các Quốc gia
  Future<List<AdministrativeUnit>> getCountries();

  /// Lấy danh sách Tỉnh/Thành theo Quốc gia
  Future<List<AdministrativeUnit>> getProvinces(String countryName);

  /// Lấy danh sách Quận/Huyện theo Tỉnh/Thành (và Quốc gia nếu cần)
  Future<List<AdministrativeUnit>> getDistricts(String countryName, String provinceName);

  /// Lấy danh sách Phường/Xã theo Quận/Huyện (và Quốc gia nếu cần)
  Future<List<AdministrativeUnit>> getWards(String countryName, String districtName);
}
